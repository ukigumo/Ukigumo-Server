use strict;
use warnings;
use utf8;
use Test::More;

use Ukigumo::Server::Command::Report;
use Ukigumo::Server;

my $c = Ukigumo::Server->bootstrap();

my $report_id = Ukigumo::Server::Command::Report->insert(
    project => 'Foo',
    branch => 'bar',
    status => 2,
    body => 'いやいや',
);
my $dat = Ukigumo::Server::Command::Report->find(
    report_id => $report_id,
);
is($dat->{body}, 'いやいや');

done_testing;

