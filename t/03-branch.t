use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Test::Requires 'LWP::Protocol::PSGI';

use Ukigumo::Constants;
use Ukigumo::Server::Command::Report;
use LWP::UserAgent;

my $guard = t::Util::Guard->new;
my $app = Plack::Util::load_psgi('app.psgi');
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

