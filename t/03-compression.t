use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Plack::Util;

use Ukigumo::Server;
use Ukigumo::Server::Command::Report;

my $app = test_ukigumo;
my $c = Ukigumo::Server->bootstrap;


subtest "compress large data" => sub {
    $c->config->{enable_compression} = 1;

    my $id = Ukigumo::Server::Command::Report->insert(
        project => 'MyProj',
        branch  => 'master',
        status  => 1,
        body    => 'body' x 100,
        vc_log  => 'vc_log' x 100,
    );

    my $row = $c->db->single('report', { report_id => $id })->get_columns;
    isnt $row->{body}, 'body' x 100;
    isnt $row->{vc_log}, 'vc_log' x 100;

    my $report = Ukigumo::Server::Command::Report->find(report_id => $id);
    is $report->{body}, 'body' x 100;
    is $report->{vc_log}, 'vc_log' x 100;
    ok utf8::is_utf8($report->{body});
    ok utf8::is_utf8($report->{vc_log});
};

subtest "not compress small data" => sub {
    $c->config->{enable_compression} = 1;

    my $id = Ukigumo::Server::Command::Report->insert(
        project => 'MyProj',
        branch  => 'master',
        status  => 1,
        body    => 'body あいやー',
        vc_log  => 'vc_log そいやー',
    );

    my $row = $c->db->single('report', { report_id => $id })->get_columns;
    is $row->{body}, 'body あいやー';
    is $row->{vc_log}, 'vc_log そいやー';

    my $report = Ukigumo::Server::Command::Report->find(report_id => $id);
    is $report->{body}, 'body あいやー';
    is $report->{vc_log}, 'vc_log そいやー';
    ok utf8::is_utf8($report->{body});
    ok utf8::is_utf8($report->{vc_log});
};

subtest "enable_compression option is false" => sub {
    $c->config->{enable_compression} = 0;

    my $id = Ukigumo::Server::Command::Report->insert(
        project => 'MyProj',
        branch  => 'master',
        status  => 1,
        body    => 'body' x 100,
        vc_log  => 'vc_log'x 100,
    );

    my $row = $c->db->single('report', { report_id => $id })->get_columns;
    is $row->{body}, 'body' x 100;
    is $row->{vc_log}, 'vc_log' x 100;

    my $report = Ukigumo::Server::Command::Report->find(report_id => $id);
    is $report->{body}, 'body' x 100;
    is $report->{vc_log}, 'vc_log' x 100;
    ok utf8::is_utf8($report->{body});
    ok utf8::is_utf8($report->{vc_log});
};

subtest "multibytes" => sub {
    $c->config->{enable_compression} = 1;

    my $id = Ukigumo::Server::Command::Report->insert(
        project => 'MyProj',
        branch  => 'master',
        status  => 1,
        body    => 'あいやー' x 100,
        vc_log  => 'そいやー' x 100,
    );

    my $row = $c->db->single('report', { report_id => $id })->get_columns;
    isnt $row->{body}, 'あいやー' x 100;
    isnt $row->{vc_log}, 'そいやー' x 100;

    my $report = Ukigumo::Server::Command::Report->find(report_id => $id);
    is $report->{body}, 'あいやー' x 100;
    is $report->{vc_log}, 'そいやー' x 100;
    ok utf8::is_utf8($report->{body});
    ok utf8::is_utf8($report->{vc_log});
};

subtest "with no warnings of Encode.pm" => sub {
    my $warned = 0;
    local $SIG{__WARN__} = sub {
        $warned++;
    };

    $c->config->{enable_compression} = 1;

    my $id = Ukigumo::Server::Command::Report->insert(
        project => 'MyProj',
        branch  => 'master',
        status  => 1,
    );

    my $row = $c->db->single('report', { report_id => $id })->get_columns;

    ok !$warned;
};

done_testing;
