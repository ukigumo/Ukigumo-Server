package Ukigumo::Server::Launcher;
use strict;
use warnings;
use feature ':5.10';

use Carp ();
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
        my $session_dir = File::Spec->catdir(File::Spec->tmpdir(), "ukigumo-session-$env");
        mkpath($session_dir);
        $session_dir;
    };
}

sub setup {
    my $app = Ukigumo::Server->new();
    $app->setup_schema();
}

sub set_config {
    my ($class, $file) = @_;

    my $config;
    if (ref $file && ref $file eq 'HASH') {
        $config = $file;
    }
    else {
        $file ||= File::Spec->catfile(Ukigumo::Server->share_dir, qw/config development.pl/);

        $config = do $file;
        Carp::croak("$file: $@") if $@;
        Carp::croak("$file: $!") unless defined $config;
        unless ( ref($config) eq 'HASH' ) {
            Carp::croak("$file does not return HashRef.");
        }
    }
    Ukigumo::Server->config($config);
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
