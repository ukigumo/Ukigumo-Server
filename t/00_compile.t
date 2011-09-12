use strict;
use warnings;
use Test::More;

use_ok $_ for qw(
    Ukigumo::Server
    Ukigumo::Server::Web
    Ukigumo::Server::Web::Dispatcher
    Ukigumo::Server::Command::Docs
);

done_testing;
