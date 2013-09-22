package Ukigumo::Server::CLI;
use strict;
use warnings;
use feature ':5.10';

use File::Spec;
use File::Path qw(mkpath);
use Plack::Builder;
use Plack::Session::Store::File;

use Ukigumo::Server;
use Ukigumo::Server::API;
use Ukigumo::Server::Web;

sub session_dir {
    state $session_dir = do {
        my $env = $ENV{PLACK_ENV} // 'cli';
        my $session_dir = File::Spec->catdir(File::Spec->tmpdir(), "ukigumo-session-$ENV{PLACK_ENV}");
        mkpath($session_dir);
        $session_dir;
    };
}

sub setup {
    my $app = Ukigumo::Server->new();
    $app->setup_schema();
}

sub to_app {
    my $class = shift;
    builder {
        enable 'Plack::Middleware::ReverseProxy';

        my $api = Ukigumo::Server::API->to_app();
        my $ui = builder {
            enable 'Plack::Middleware::Static',
              path => qr{^(?:/static/|/robot\.txt$|/favicon.ico$)},
              root => File::Spec->catdir( Ukigumo::Server->share_dir );
            enable 'Plack::Middleware::Session',
                store => Plack::Session::Store::File->new(
                    dir => $class->session_dir,
                );
            Ukigumo::Server::Web->to_app();
        };

        sub {
            my $env = shift;
            if ($env->{PATH_INFO} =~ m{^/api/}) {
                $api->($env);
            } else {
                $ui->($env);
            }
        };
    };
}

1;
