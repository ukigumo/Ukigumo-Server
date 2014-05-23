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

    $c->config->{max_num_of_reports_by_branch} = 3;
    $c->config->{max_num_of_reports} = 5;

    my $reports_1 = [];
    for my $rev (1..4) {
        push @$reports_1, Ukigumo::Server::Command::Report->insert(
            project => 'MyProj1',
            branch  => 'master',
            status  => '1',
            revision => $rev,
        );
    }

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_1->[0]), 'deleted by max_num_of_reports_by_branch';
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

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_2->[0]), 'deleted by max_num_of_reports_by_branch';
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[1]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[2]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_2->[3]);

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports_1->[1]), 'deleted by max_num_of_reports';
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[2]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports_1->[3]);
};

subtest 'remove the branch when it has no reports' => sub {
    $c->dbh->selectall_arrayref(q{DELETE FROM report});

    $c->config->{max_num_of_reports_by_branch} = 2;
    $c->config->{max_num_of_reports} = 2;

    my @reports;
    my $project = 'MyProj1';

    push @reports, Ukigumo::Server::Command::Report->insert(
        project => $project,
        branch  => 'master',
        status  => '1',
        revision => 1,
    );

    push @reports, Ukigumo::Server::Command::Report->insert(
        project => $project,
        branch  => 'forked',
        status  => '1',
        revision => 2,
    );

    push @reports, Ukigumo::Server::Command::Report->insert(
        project => $project,
        branch  => 'forked',
        status  => '1',
        revision => 3,
    );

    ok !Ukigumo::Server::Command::Report->find(report_id => $reports[0]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports[1]);
    ok +Ukigumo::Server::Command::Report->find(report_id => $reports[2]);

    ok !Ukigumo::Server::Command::Branch->find(
        project => $project,
        branch  => 'master',
    );

    ok +Ukigumo::Server::Command::Branch->find(
        project => $project,
        branch  => 'forked',
    );
};

done_testing;
