#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Test::Requires 'LWP::Protocol::PSGI', 'LWP::UserAgent', 'Capture::Tiny';
use Capture::Tiny qw(tee_merged);
use LWP::UserAgent;
use Plack::Util;
use HTTP::Message::PSGI;
use LWP::Protocol::PSGI;
use Data::Dumper;

my $app = test_ukigumo;
LWP::Protocol::PSGI->register($app);

my $c = Ukigumo::Server->bootstrap();

my $ua = LWP::UserAgent->new();
subtest 'no body' => sub {
    my $res = $ua->post(
        "http://localhost/api/v1/report/add",
        [
            status   => 1,             # status code: SUCCESS:1, FAIL:2, N/A:3
            project  => 'MyProj',      # project name
            branch   => 'master',       # branch name
            revision => 3,
            repo     => 'git://...',
        ]
    );
    ok($res->is_success) or die $res->status_line;
};

$c->dbh->selectall_arrayref(q{DELETE FROM report});
subtest 'on body' => sub {
    my $res = $ua->post(
        "http://localhost/api/v1/report/add",
        [
            body => 'OKXXX',
            status   => 1,             # status code: SUCCESS:1, FAIL:2, N/A:3
            project  => 'MyProj',      # project name
            branch   => 'master',       # branch name
            revision => 3,
            repo     => 'git://...',
        ]
    );
    ok($res->is_success) or die $res->status_line;
};

is($c->dbh->selectrow_array(q{SELECT COUNT(*) FROM report WHERE body="OKXXX"}), 1);

done_testing;
