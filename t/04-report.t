use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Test::Requires 'LWP::Protocol::PSGI';

use Ukigumo::Constants;
use Ukigumo::Server::Command::Report;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new();

subtest 'raw' => sub {
    my $app  = test_ukigumo;
    LWP::Protocol::PSGI->register($app);
    my $c = Ukigumo::Server->bootstrap;

    Ukigumo::Server::Command::Report->insert(
        project => 'Foo',
        branch  => 'bar',
        status  => STATUS_SUCCESS,
    );

    subtest 'exist' => sub {
        my $res = $ua->get('http://localhost/report/1');
        is($res->code, 200);
    };

    subtest 'not found' => sub {
        my $res = $ua->get('http://localhost/report/2');
        is($res->code, 404);
    };
};

subtest 'compressed' => sub {
    my $app  = test_ukigumo;
    LWP::Protocol::PSGI->register($app);
    my $c = Ukigumo::Server->bootstrap;
    $c->config->{enable_compression} = 1;

    Ukigumo::Server::Command::Report->insert(
        project => 'Foo',
        branch  => 'bar',
        status  => STATUS_SUCCESS,
    );

    subtest 'exist' => sub {
        my $res = $ua->get('http://localhost/report/1');
        is($res->code, 200);
    };

    subtest 'not found' => sub {
        my $res = $ua->get('http://localhost/report/2');
        is($res->code, 404);
    };
};

done_testing;

