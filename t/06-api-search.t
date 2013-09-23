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
use JSON;
use Ukigumo::Constants;

my $app = test_ukigumo;
LWP::Protocol::PSGI->register($app);

my $c = Ukigumo::Server->bootstrap();

my $ua = LWP::UserAgent->new();
subtest 'zero report' => sub {
    my $res = $ua->get(
        "http://localhost/api/v1/report/search?project=Foo&branch=master&revision=xxx",
    );
    ok($res->is_success) or die $res->status_line;
    my $dat = decode_json($res->decoded_content);
    is_deeply($dat, { reports => [] }) or diag(Dumper $dat);
};

subtest 'one report' => sub {
    Ukigumo::Server::Command::Report->insert(
        project  => 'Foo',
        branch   => 'master',
        revision => 'xxx',
        body     => 'ok',
        status   => STATUS_SUCCESS,
    );

    my $res = $ua->get(
        "http://localhost/api/v1/report/search?project=Foo&branch=master&revision=xxx",
    );
    ok($res->is_success) or die $res->status_line;
    my $dat = decode_json($res->decoded_content);
    is(ref $dat->{reports}, 'ARRAY') or BAIL_OUT;
    is(0+@{$dat->{reports}}, 1) or BAIL_OUT;
    is(join(',', sort keys(%{$dat->{reports}->[0]})), 'ctime,report_id,status') or BAIL_OUT;
    like($dat->{reports}->[0]->{ctime}, qr/^[0-9]+$/) or BAIL_OUT;
};


done_testing;
