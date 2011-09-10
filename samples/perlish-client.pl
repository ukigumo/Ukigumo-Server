#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Capture::Tiny qw(tee_merged);
use LWP::UserAgent;

my $failed = 0;
sub run {
    system(@_)==0 or die "FAIL: @_";
}

my $body = tee_merged {
    eval {
        run("git pull");
        run("perl Makefile.PL");
        run("make test");
    };
    if ($@) {
        $failed++;
        warn $@;
    }
};

my $revision = substr( `git rev-parse HEAD`, 0, 10 ) || 'Unknown';
my $branch   = `git branch|grep '^*'`;
   $branch =~ s/^\* //;
   $branch =~ s/\s*$//;
my $repository = `git remote -v | head -1| awk '{print \$2}'`;
   $repository =~ s/\n//;

print "'$revision', '$repository', '$branch'\n";

my $ua = LWP::UserAgent->new();
my $res = $ua->post(
    'http://localhost:9052/api/v1/report/add',
    [
        status   => $failed ? 2 : 1,             # status code: SUCCESS:1, FAIL:2, N/A:3
        project  => 'MyProj',      # project name
        branch   => $branch,       # branch name
        body     => $body,
        revision => $revision,
        repo     => $repository,
    ]
);
$res->is_success or die $res->as_string;


