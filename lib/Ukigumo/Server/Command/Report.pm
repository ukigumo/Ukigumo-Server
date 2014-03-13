package Ukigumo::Server::Command::Report;
use strict;
use warnings;
use utf8;
use 5.010001;

use Amon2::Declare;
use URI::WithBase;
use Data::Page::NoTotalEntries;
use Data::Validator;
use Ukigumo::Server::Command::Branch;
use Compress::Zlib;
use Encode;

sub get_last_status {
    my $class = shift;
    state $rule = Data::Validator->new(
        project => { isa => 'Str' },
        branch  => { isa => 'Str' },
    );
    my $args = $rule->validate(@_);

    my $itr = c->db->search_by_sql(
        q{SELECT status FROM report INNER JOIN branch ON (report.report_id=branch.last_report_id) WHERE
            branch.project = ? AND
            branch.branch  = ?
        ORDER BY report_id DESC LIMIT 1},
        [$args->{project}, $args->{branch}],
    );
    $itr->suppress_object_creation(1);

    my $row = $itr->next || {};
    $row->{status};
}

sub recent_list {
    my $class = shift;
    state $rule = Data::Validator->new(
        limit   => { isa => 'Int', default => 50 },
        page    => { isa => 'Int', default => 1 },
    );
    my $args = $rule->validate(@_);

    my $itr = c->db->search_by_sql(
        q{SELECT branch.project, branch.branch, report.report_id, report.revision, report.status, report.ctime
        FROM report INNER JOIN branch ON (branch.branch_id=report.branch_id)
        ORDER BY report_id DESC
        LIMIT ? OFFSET ?},
        [$args->{limit} + 1, $args->{limit}*($args->{page}-1)],
    );
    $itr->suppress_object_creation(1);
    my $reports = [$itr->all];
    my $has_next = do {
        if (@$reports == $args->{limit}+1) {
            pop @$reports;
            1;
        } else {
            0;
        }
    };
    my $pager = Data::Page::NoTotalEntries->new(
        has_next             => $has_next,
        entries_per_page     => $args->{limit},
        current_page         => $args->{page},
        entries_on_this_page => scalar @$reports,
    );
    return wantarray ? ($reports, $pager) : $reports;
}

sub failure_list {
    my $class = shift;
    state $rule = Data::Validator->new(
        limit   => { isa => 'Int', default => 50 },
        page    => { isa => 'Int', default => 1 },
    );
    my $args = $rule->validate(@_);

    my $itr = c->db->search_by_sql(
        q{SELECT branch.project, branch.branch, report.report_id, report.revision, report.status, report.ctime
        FROM report INNER JOIN branch ON (branch.branch_id=report.branch_id)
        WHERE NOT report.status = 1
        ORDER BY report_id DESC
        LIMIT ? OFFSET ?}, [$args->{limit} + 1, $args->{limit}*($args->{page}-1)],
    );
    $itr->suppress_object_creation(1);
    my $reports = [$itr->all];
    my $has_next = do {
        if (@$reports == $args->{limit}+1) {
            pop @$reports;
            1;
        } else {
            0;
        }
    };
    my $pager = Data::Page::NoTotalEntries->new(
        has_next             => $has_next,
        entries_per_page     => $args->{limit},
        current_page         => $args->{page},
        entries_on_this_page => scalar @$reports,
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

    my $itr = c->db->search(report => {
        branch_id => $args->{branch_id},
    }, {
        limit    => $args->{limit} + 1,
        offset   => $args->{limit}*($args->{page}-1),
        order_by => 'report_id DESC',
        columns  => [qw/report_id revision status ctime/],
    });
    $itr->suppress_object_creation(1);

    my $reports = [$itr->all];
    my $has_next = do {
        if (@$reports == $args->{limit}+1) {
            pop @$reports;
            1;
        } else {
            0;
        }
    };
    my $pager = Data::Page::NoTotalEntries->new(
        has_next             => $has_next,
        entries_per_page     => $args->{limit},
        current_page         => $args->{page},
        entries_on_this_page => scalar @$reports,
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

    my $itr = c->db->search_by_sql(
        q{SELECT status, report_id, report.ctime FROM report INNER JOIN branch ON (branch.branch_id=report.branch_id) WHERE
            project  = ? AND
            branch   = ? AND
            revision = ?
        ORDER BY report_id DESC LIMIT ?
        }, [$args->{project}, $args->{branch}, $args->{revision}, $args->{limit}]);
    $itr->suppress_object_creation(1);

    [$itr->all];
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
        compare_url => { isa => 'Str', optional => 1 },
    );
    my $args = $rule->validate(@_);

    my $txn = c->db->txn_scope;

    my $branch_id = Ukigumo::Server::Command::Branch->find_or_create(
        project => $args->{project},
        branch  => $args->{branch},
    );
    my $report_id = do {
        my %params = %$args;
        delete $params{project};
        delete $params{branch};

        c->db->fast_insert(report => $class->_compress_text_data({
            %params,
            ctime     => time(),
            branch_id => $branch_id,
        }));
    };

    c->db->update(branch => {
        last_report_id => $report_id,
    }, {
        branch_id => $branch_id,
    });

    if (defined c->config->{max_report_size_by_branch}) {
        my $last = [ c->db->search_named(q{ SELECT report_id FROM report WHERE branch_id = :branch_id ORDER BY report_id DESC LIMIT :limit }, {
            limit     => c->config->{max_report_size_by_branch},
            branch_id => $branch_id,
        }) ]->[-1];

        c->db->delete('report', {
            report_id => { '<' => $last->report_id },
            branch_id => $branch_id,
        });
    }

    if (defined c->config->{max_report_size}) {
        my $last = [ c->db->search_named(q{ SELECT report_id FROM report ORDER BY report_id DESC LIMIT :limit }, {
            limit     => c->config->{max_report_size},
        }) ]->[-1];

        c->db->delete('report', {
            report_id => { '<' => $last->report_id },
        });
    }

    $txn->commit;

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

    local c->db->{suppress_row_objects} = 1;
    return $class->_uncompress_text_data(c->db->single_by_sql(
        q{SELECT branch.project, branch.branch, report.* FROM report INNER JOIN branch ON (report.branch_id=branch.branch_id) WHERE report_id=?},
        [$args->{report_id}]
    ));
}

sub _compress_text_data {
    my ($self, $row) = @_;
    c->config->{enable_compression} or return $row;
    $row->{$_} = __compress(encode_utf8($row->{$_})) for qw(vc_log body);
    $row;
}

sub _uncompress_text_data {
    my ($self, $row) = @_;
    c->config->{enable_compression} or return $row;
    $row->{$_} = decode_utf8(__uncompress($row->{$_})) for qw(vc_log body);
    $row;
}

sub __compress {
    my $bytes = Compress::Zlib::memGzip(\ $_[0]) ;
    if (length($bytes) < length($_[0])) {
        return $bytes;
    }
    $_[0];
}


sub __uncompress {
    # Only uncompress with gzip header
    if (
        substr($_[0], 0, length(IO::Compress::Gzip::Constants::GZIP_MINIMUM_HEADER)) eq 
        IO::Compress::Gzip::Constants::GZIP_MINIMUM_HEADER
    ) {
        return Compress::Zlib::memGunzip(\$_[0]) ;
    }
    $_[0];
}

1;
