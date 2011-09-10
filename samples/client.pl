#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
my $res = $ua->post('http://localhost:9052/api/v1/report/add', [
    status => 1, # status code: SUCCESS:1, FAIL:2, N/A:3
    project => 'MyProj', # project name
    branch  => 'master', # branch name
    vc_log  => <<'...',  # optional
commit 80202d0952c6f7d9aeb6dc24a12484e47e212c28
Author: Tokuhiro Matsuno <tokuhirom@gmail.com>
Date:   Tue Sep 6 10:11:08 2011 +0900

do not index production.pl
...
    body => <<'...',     # test report body
うーむ。。
t/00_compile.t .. 
1..1
ok 1 - use Acme::Failing;
ok
t/01_fail.t ..... 
not ok 1 - oops..
1..1

#   Failed test 'oops..'
#   at t/01_fail.t line 6.
# Looks like you failed 1 test of 1.
Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/1 subtests 

Test Summary Report
-------------------
t/01_fail.t   (Wstat: 256 Tests: 1 Failed: 1)
  Failed test:  1
  Non-zero exit status: 1
Files=2, Tests=2,  0 wallclock secs ( 0.04 usr  0.01 sys +  0.05 cusr  0.02 csys =  0.12 CPU)
Result: FAIL
...
    revision => '80202d0952c6f7d9aeb6dc24a12484e47e212c28', # revision hash/number
    repo     => 'git://github.com/tokuhirom/Acme-Failing.git', # repository uri
]);
$res->is_success or die $res->as_string;

