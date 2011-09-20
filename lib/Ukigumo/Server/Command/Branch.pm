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
        my ( $sql, @bind ) = sql_interp 'INSERT OR IGNORE INTO branch ',
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
    c->dbh->selectrow_array( q{DELETE FROM branch WHERE branch_id=?}, {}, $args->{branch_id} );
    c->dbh->selectrow_array( q{DELETE FROM report WHERE branch_id=?}, {}, $args->{branch_id} );
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
            sql_interp q{SELECT branch.project, branch.branch AS branch, report.report_id, report.status, report.revision, report.ctime FROM branch LEFT JOIN report ON (branch.last_report_id=report.report_id) WHERE }, $args, q{ORDER BY last_report_id DESC};

        @{ c->dbh->selectall_arrayref( $sql, { Slice => +{} }, @binds, ) };
    };
    for my $project (@projects) {
       $project->{ctime} = Time::Piece->new($project->{ctime});
    }
    return \@projects;
}

1;

