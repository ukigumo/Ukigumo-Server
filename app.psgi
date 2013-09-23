use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');

use Ukigumo::Server::Launcher;

Ukigumo::Server::Launcher->setup;
Ukigumo::Server::Launcher->to_app;
