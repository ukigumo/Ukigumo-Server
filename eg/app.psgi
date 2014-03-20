use File::Spec;
use File::Basename;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Ukigumo::Server::Launcher;

Ukigumo::Server::Launcher->setup;
Ukigumo::Server::Launcher->to_app;
