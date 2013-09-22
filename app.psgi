use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');

use Ukigumo::Server::CLI;

Ukigumo::Server::CLI->setup;
Ukigumo::Server::CLI->to_app;
