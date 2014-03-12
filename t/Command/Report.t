#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

use Ukigumo::Server;
use Ukigumo::Server::Command::Report;

my $app = test_ukigumo;
my $c = Ukigumo::Server->bootstrap;

subtest 'remove old report' => sub {
    $c->dbh->selectall_arrayref(q{DELETE FROM report});

    $c->config->{max_report_size_by_branch} = 3;
    $c->config->{max_report_size} = 5;

    my $reports_1 = [];
    for my $rev (1..4) {
        push @$reports_1, Ukigumo::Server::Command::Report->insert(
            project => 'MyProj1',
            branch  => 'master',
            status  => '1',
            revision => $rev,
        );
    }

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_1->[0]), 'deleted by max_report_size_by_branch';
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[1]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[2]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[3]);

    my $reports_2 = [];
    for my $rev (1..4) {
        push @$reports_2, Ukigumo::Server::Command::Report->insert(
            project => 'MyProj2',
            branch  => 'master',
            status  => '1',
            revision => $rev,
        );
    }

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_2->[0]), 'deleted by max_report_size_by_branch';
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[1]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[2]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[3]);

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_1->[1]), 'deleted by max_report_size';
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[2]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[3]);
};

done_testing;
