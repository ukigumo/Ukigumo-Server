use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;
use Plack::Util;
use Test::Requires 'LWP::Protocol::PSGI', 'LWP::UserAgent';
use JSON;
use FindBin;
use File::Spec::Functions qw/catfile/;

my $app = test_ukigumo;
my $c   = Ukigumo::Server->bootstrap;
LWP::Protocol::PSGI->register($app);

my $ua = LWP::UserAgent->new();

subtest 'add report' => sub {
    subtest 'basic' => sub {
        my $url = do {
            my @branch = 'master';
            my $res = $ua->post('http://localhost/api/v1/report/add', [
                project => 'TestingProject',
                branch => $branch[int rand @branch],
                revision => 3,
                status  => 1,
                body    => '....',
                repo => 'git://...',
                vc_log => 'testtest',
            ]);
            is $res->code, 200;
            note $res->content;
            my $dat = decode_json($res->content);
            my $report_id = $dat->{report}->{report_id};
            like $report_id, qr{^[0-9]+$};
            like $dat->{report}->{url}, qr{^http://};
            is $dat->{report}->{last_status}, undef;

            my $got = $c->db->single_by_sql(q{ SELECT body FROM report WHERE report_id = ? }, [$report_id]);
            is $got->body, '....';

            $dat->{report}->{url};
        };

        subtest 'get ok' => sub {
            my $res = $ua->get($url);
            is($res->code, 200, $url) or note $res->content;
        };

        subtest 'not found' => sub {
            my $url = 'http://localhost/report/9999999999';
            my $res = $ua->get($url);
            is $res->code, 404, $url;
        };

        subtest 'got last status successfully' => sub {
            my $res = $ua->post('http://localhost/api/v1/report/add', [
                project => 'TestingProject',
                branch => 'master',
                revision => 3,
                status  => 2,
                body    => '....',
                repo => 'git://...',
            ]);
            is $res->code, 200;
            note $res->content;
            my $dat = decode_json($res->content);
            is $dat->{report}->{last_status}, 1;
        };
    };

    subtest 'with uploaded body' => sub {
        my $log_file = catfile($FindBin::Bin, 'resources', 'report.log');

        my $res = $ua->post(
            'http://localhost/api/v1/report/add',
            [
                project  => 'TestingProject',
                branch   => 'master',
                revision => 3,
                status   => 1,
                repo     => 'git://...',
                body     => [$log_file],
            ],
            Content_Type => 'form-data',
        );
        is $res->code, 200;
        note $res->content;

        my $dat = decode_json($res->content);
        my $report_id = $dat->{report}->{report_id};

        open my $fh, '<', $log_file;
        my $expected_body = do { local $/; <$fh> };
        my $got = $c->db->single_by_sql(q{ SELECT body FROM report WHERE report_id = ? }, [$report_id]);
        is $got->body, $expected_body;
    };

    subtest 'validation error' => sub {
        my $res = $ua->post('http://localhost/api/v1/report/add', [
            # project => 'TestingProject', # <= do not pass this parameter.
            branch => 'master',
            revision => 3,
            status  => 2,
            body    => '....',
            repo => 'git://...',
        ]);
        is $res->code, 400;
        note $res->content;
        my $dat = decode_json($res->content);
        like $dat->{error}->{message}, qr{Missing parameter: 'project'};
    };
};

subtest 'api list' => sub {
    my $res = $ua->get(
        'http://localhost/api/v1/report/search?project=TestingProject&branch=master&revision=3',
    );
    is $res->code, 200;
    note $res->content;
    my $dat = decode_json($res->content);
    for (@{$dat->{reports}}) { delete $_->{ctime}; }
    is_deeply $dat,
      {
        'reports' => [
            {
                'status'    => 1,
                'report_id' => 3
            },
            {
                'status'    => 2,
                'report_id' => 2
            },
            {
                'status'    => 1,
                'report_id' => 1
            },
        ]
      };
};

subtest 'api branch list' => sub {
    my $res = $ua->get(
        'http://localhost/api/v1/branch/list?project=TestingProject',
    );
    is $res->code, 200;
    note $res->content;
    my $dat = decode_json($res->content);
    is ref($dat->{branches}), 'ARRAY';
    is 0+@{$dat->{branches}}, 1;
    is $dat->{branches}->[0]->{branch}, 'master';
};

subtest 'api branch delete' => sub {
    my $res = $ua->post(
        'http://localhost/api/v1/branch/delete?project=TestingProject&branch=master',
    );
    is $res->code, 200;
    note $res->content;
    my $dat = decode_json($res->content);
    is_deeply $dat, +{ };
};

subtest 'api branch list' => sub {
    my $res = $ua->get(
        'http://localhost/api/v1/branch/list?project=TestingProject',
    );
    is $res->code, 200;
    note $res->content;
    my $dat = decode_json($res->content);
    is ref($dat->{branches}), 'ARRAY';
    is 0+@{$dat->{branches}}, 0, 'removed';
};

done_testing;
