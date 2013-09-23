use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Test::Requires 'LWP::Protocol::PSGI';

use Ukigumo::Constants;
use Ukigumo::Server::Command::Report;
use LWP::UserAgent;

my $app  = test_ukigumo;
LWP::Protocol::PSGI->register($app);

my $c = Ukigumo::Server->bootstrap;
Ukigumo::Server::Command::Report->insert(
    project => 'Foo',
    branch  => 'feature/bar',
    status  => STATUS_SUCCESS,
);

my $ua = LWP::UserAgent->new();
my $res = $ua->get('http://localhost/project/Foo/feature%2Fbar');
is($res->code, 200);

done_testing;

