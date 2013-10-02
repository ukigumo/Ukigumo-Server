package Ukigumo::Server::Schema;
use strict;
use warnings;
use utf8;

use DBIx::Schema::DSL;

default_not_null;

create_table branch => columns {
    pk      'branch_id';
    varchar 'project';
    varchar 'branch';
    integer 'last_report_id', null;
    integer 'ctime';

    add_unique_index 'project_branch_uniq', [qw/project branch/];
};

create_table report => columns {
    pk      'report_id';
    integer 'branch_id';
    tinyint 'status'; # 1: success, 2: fail, 3:na
    text    'repo',     null;
    varchar 'revision', null;
    text    'vc_log',  null;
    text    'body',    null;
    integer 'ctime';

    add_index report_branch_idx => [qw/branch_id/];
};

1;
