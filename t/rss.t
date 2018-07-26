use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/..";
use t::Util;
use Plack::Test;
use Plack::Util;
use Test::More;

my $app = test_ukigumo;
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new(GET => 'http://localhost/rss.xml');
        my $res = $cb->($req);
        is $res->code, 200;
        diag $res->content if $res->code != 200;
        like ($res->content, qr/<rss/, 'RSS');
    };

done_testing;
