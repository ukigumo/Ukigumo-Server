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
        c->dbh->do( $sql, {}, @bind );
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
    return c->dbh->selectrow_array( q{SELECT branch_id FROM branch WHERE project=? AND branch=?}, {}, $args->{project}, $args->{branch} );
}

sub lookup {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);
    return c->dbh->selectrow_hashref( q{SELECT * FROM branch WHERE branch_id=?}, {}, $args->{branch_id} );
}

sub delete {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);
    if (c->dbdriver eq 'mysql') {
        c->dbh->do( q{DELETE FROM report WHERE branch_id=?}, {}, $args->{branch_id} );

        my @branch = c->dbh->selectrow_array( q{SELECT branch FROM branch WHERE branch_id=?}, {}, $args->{branch_id} );
        if (scalar(@branch) == 1) {
            c->dbh->do( q{DELETE FROM branch WHERE branch=?}, {}, $branch[0]);
        } else {
            Carp::carp "Failed to delete branch data. Because several branches have same branch_id: $args->{branch_id}";
        }
    } else {
        c->dbh->selectrow_array( q{DELETE FROM branch WHERE branch_id=?}, {}, $args->{branch_id} );
        c->dbh->selectrow_array( q{DELETE FROM report WHERE branch_id=?}, {}, $args->{branch_id} );
    }
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

