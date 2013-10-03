use File::Spec;
use File::Basename;
use FindBin::libs;

use Ukigumo::Server::Launcher;

Ukigumo::Server::Launcher->setup;
Ukigumo::Server::Launcher->to_app;
