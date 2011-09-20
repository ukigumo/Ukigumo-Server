use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Ukigumo::Server;
use Ukigumo::Server::API;
use Ukigumo::Server::Web;
use Plack::Session::Store::File;
use File::Path qw(mkpath);

my $session_dir = File::Spec->catdir(File::Spec->tmpdir(), "ukigumo-session-$ENV{PLACK_ENV}");
mkpath($session_dir);

{
	my $app = Ukigumo::Server->new();
	$app->setup_schema();
}

builder {
    enable 'Plack::Middleware::ReverseProxy';

    my $api = Ukigumo::Server::API->to_app();
    my $ui = builder {
        enable 'Plack::Middleware::Static',
          path => qr{^(?:/static/|/robot\.txt$|/favicon.ico$)},
          root => File::Spec->catdir( dirname(__FILE__) );
        enable 'Plack::Middleware::Session',
            store => Plack::Session::Store::File->new(
                dir => $session_dir,
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
