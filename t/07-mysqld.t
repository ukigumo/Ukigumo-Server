use strict;
use warnings;
use utf8;
use Test::More;
use Test::Requires 'Test::mysqld';

use Ukigumo::Server::Command::Report;
use Ukigumo::Server;

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '', # no TCP socket
    }
) or plan skip_all => $Test::mysqld::errstr;

Ukigumo::Server->config({
    'DBI' => [$mysqld->dsn, '', '', {
        mysql_enable_utf8 => 1,
    }],
});

my $c = Ukigumo::Server->bootstrap();
$c->setup_schema;

my $report_id = Ukigumo::Server::Command::Report->insert(
    project => 'Foo',
    branch => 'bar',
    status => 2,
    body => 'いやいや',
);
{
    my ($branch_num) = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM branch});
    is($branch_num, 1);
    my ($report_num) = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM report});
    is($report_num, 1);
}
my $dat = Ukigumo::Server::Command::Report->find(
    report_id => $report_id,
);
is($dat->{body}, 'いやいや');
my $branch_id = $dat->{branch_id};
ok($branch_id);

Ukigumo::Server::Command::Branch->delete(
    branch_id => $branch_id,
);
{
    my ($branch_num) = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM branch});
    is($branch_num, 0);
    my ($report_num) = $c->dbh->selectrow_array(q{SELECT COUNT(*) FROM report});
    is($report_num, 0, 'report was deleted');
}

done_testing;
