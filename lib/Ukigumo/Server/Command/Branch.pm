use strict;
use warnings;
use utf8;
use 5.010001;

package Ukigumo::Server::Command::Branch;
use Time::Piece;
use SQL::Interp qw(:all);
use Amon2::Declare;

sub find_or_create {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    do {
        my $base_sql;
        if (c->dbdriver eq 'mysql') {
            $base_sql = 'INSERT IGNORE INTO branch ';
        } else {
            $base_sql = 'INSERT OR IGNORE INTO branch ';
        }
        my ( $sql, @bind ) = sql_interp $base_sql,
          +{
            project        => $args->{project},
            branch         => $args->{branch},
            ctime          => time(),
          };
        c->db->execute( $sql, \@bind );
    };

    return $class->find(%$args);
}

sub find {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    return c->db->single(branch => {project => $args->{project}, branch => $args->{branch}})->branch_id;
}

sub lookup {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);
    return c->db->single(branch => {branch_id => $args->{branch_id}})->get_columns;
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
        project => { isa => 'Str', optional => 1 },
    );
    my $args = $rule->validate(@_);

    my @projects = do {
        my ($sql, @binds) =
            sql_interp q{SELECT DISTINCT branch.project, branch.branch AS branch, report.report_id, report.status, report.revision, report.ctime FROM branch LEFT JOIN report ON (branch.last_report_id=report.report_id) WHERE }, $args, q{ORDER BY last_report_id DESC};

        @{ c->dbh->selectall_arrayref( $sql, { Slice => +{} }, @binds, ) };
    };
    return \@projects;
}

1;
