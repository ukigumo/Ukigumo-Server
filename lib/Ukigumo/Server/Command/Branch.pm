package Ukigumo::Server::Command::Branch;
use strict;
use warnings;
use utf8;
use 5.010001;

use Amon2::Declare;
use Data::Validator;

sub find_or_create {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    my $base_sql = c->dbdriver eq 'mysql' ? 'INSERT IGNORE INTO' : 'INSERT OR IGNORE INTO';
    c->db->fast_insert(branch => {
        project        => $args->{project},
        branch         => $args->{branch},
        ctime          => time(),
    }, $base_sql);

    return $class->find(%$args);
}

sub find {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    local c->db->{suppress_row_objects} = 1;
    return c->db->single(branch => {project => $args->{project}, branch => $args->{branch}})->{branch_id};
}

sub lookup {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);
    local c->db->{suppress_row_objects} = 1;
    return c->db->single(branch => {branch_id => $args->{branch_id}});
}

sub delete {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);
    c->db->delete(branch => {branch_id => $args->{branch_id}});
    c->db->delete(report => {branch_id => $args->{branch_id}});
    return;
}

sub list {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str',      optional => 1 },
        status  => { isa => 'ArrayRef', optional => 1 },
    );
    my $args = $rule->validate(@_);

    my $sql = q{SELECT DISTINCT branch.project, branch.branch, report.report_id, report.status, report.revision, report.ctime, report.elapsed_time_sec
        FROM branch LEFT JOIN report ON (branch.last_report_id=report.report_id) };
    my @wheres;
    if (exists $args->{project}) {
        push @wheres, 'project = :project ';
    }
    if (exists $args->{status}) {
        push @wheres, 'status IN :status ';
    }
    $sql .= q{WHERE } . join('AND ', @wheres) if @wheres;
    $sql .= q{ORDER BY last_report_id DESC};

    my $itr = c->db->search_named($sql, $args);
    $itr->suppress_object_creation(1);

    [$itr->all];
}

1;
