use strict;
use warnings;
use utf8;

package Ukigumo::Server::Command::Report;
use SQL::Interp qw(:all);
use Amon2::Declare;
use URI::WithBase;
use 5.010001;
use Data::Validator;
use Ukigumo::Server::Command::Branch;
use Data::Page::NoTotalEntries;

sub get_last_status {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    my ( $sql, @bind ) =
      sql_interp
q{SELECT status FROM report INNER JOIN branch ON (report.report_id=branch.last_report_id) WHERE },
      +{
        'branch.project' => $args->{project},
        'branch.branch'  => $args->{branch}
      },
      q{ ORDER BY report_id DESC LIMIT 1};
    my ($last_status) = c->dbh->selectrow_array($sql, {}, @bind);
    return $last_status;
}

sub recent_list {
    my $class = shift;
    state $rule = Data::Validator->new(
        limit   => { isa => 'Int', default => 50 },
        page    => { isa => 'Int', default => 1 },
    );
    my $args = $rule->validate(@_);

    my $reports = c->dbh->selectall_arrayref(
        q{SELECT branch.project, branch.branch, report.report_id, report.revision, report.status, report.ctime
        FROM report INNER JOIN branch ON (branch.branch_id=report.branch_id)
        ORDER BY report_id DESC
        LIMIT } . ($args->{limit} + 1) . " OFFSET " . $args->{limit}*($args->{page}-1),
        { Slice => +{} },
    );
    my $has_next = do {
        if (@$reports == $args->{limit}+1) {
            pop @$reports;
            1;
        } else {
            0;
        }
    };
    my $pager = Data::Page::NoTotalEntries->new(
        has_next => $has_next,
        entries_per_page => $args->{limit},
        current_page => $args->{page},
        entries_on_this_page => @$reports,
    );
    return wantarray ? ($reports, $pager) : $reports;
}

sub list {
    my $class = shift;
    state $rule = Data::Validator->new(
        branch_id  => { isa => 'Int' },
        limit   => { isa => 'Int', default => 50 },
        page    => { isa => 'Int', default => 1 },
    );
    my $args = $rule->validate(@_);

    my $reports = c->dbh->selectall_arrayref(
        q{SELECT report_id, revision, status, ctime FROM report WHERE branch_id=?
        ORDER BY report_id DESC
        LIMIT } . ($args->{limit} + 1) . " OFFSET " . $args->{limit}*($args->{page}-1),
        { Slice => +{} },
        $args->{branch_id}
    );
    my $has_next = do {
        if (@$reports == $args->{limit}+1) {
            pop @$reports;
            1;
        } else {
            0;
        }
    };
    my $pager = Data::Page::NoTotalEntries->new(
        has_next => $has_next,
        entries_per_page => $args->{limit},
        current_page => $args->{page},
        entries_on_this_page => @$reports,
    );
    return wantarray ? ($reports, $pager) : $reports;
}

sub search {
    my $class = shift;
    state $rule = Data::Validator->new(
        project  => { isa => 'Str' },
        branch   => { isa => 'Str' },
        revision => { isa => 'Str' },
        limit    => { isa => 'Int', default => 20 },
    );
    my $args = $rule->validate(@_);
    my %where = map { $_ => $args->{$_} } qw(project branch revision);

    my ($sql, @bind) = sql_interp q{SELECT status, report_id, report.ctime FROM report INNER JOIN branch ON (branch.branch_id=report.branch_id) WHERE }, \%where, q{ ORDER BY report_id DESC LIMIT }, $args->{limit};
    return c->dbh->selectall_arrayref($sql, +{ Slice => {}}, @bind);
}

sub insert {
    my $class = shift;
    state $rule = Data::Validator->new(
        project  => { isa => 'Str' },
        branch   => { isa => 'Str' },
        status   => { isa => 'Int' },
        repo     => { isa => 'Str', optional => 1 },
        revision => { isa => 'Str', optional => 1 },
        body     => { isa => 'Str', optional => 1 },
        vc_log   => { isa => 'Str', optional => 1 },
    );
    my $args = $rule->validate(@_);

    my $branch_id = Ukigumo::Server::Command::Branch->find_or_create(
        project => $args->{project},
        branch  => $args->{branch},
    );
    my $report_id = do {
        my %params = %$args;
        delete $params{project};
        delete $params{branch};
        my ( $sql, @bind ) = sql_interp 'INSERT INTO report ',
          +{ %params, ctime => time(), branch_id => $branch_id };
        c->dbh->do( $sql, {}, @bind );
        c->dbh->sqlite_last_insert_rowid();
    };

    do {
        my ( $sql, @bind ) = sql_interp 'UPDATE branch SET ',
          +{
            last_report_id => $report_id,
          }, q{ WHERE }, +{ branch_id => $branch_id };
        c->dbh->do( $sql, {}, @bind ) ~~ [0,1] or die;
    };

    return $report_id;
}

sub get_url {
    my ($class, $id) = @_;
    my $c = c();
    my $uri = URI::WithBase->new($c->uri_for("/report/$id"), $c->req->uri);
    $uri->abs->as_string;
}

sub find {
    my $class = shift;
    state $rule = Data::Validator->new(
        report_id => { isa => 'Int' },
    );
    my $args = $rule->validate(@_);

    my $report = c->dbh->selectrow_hashref(q{SELECT branch.project, branch.branch, report.* FROM report INNER JOIN branch ON (report.branch_id=branch.branch_id) WHERE report_id=?}, {}, $args->{report_id});
    return $report;
}

1;

