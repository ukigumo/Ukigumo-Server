#!/usr/bin/env perl
use 5.014;
use warnings;
use utf8;
use autodie;
use Path::Tiny;

my $work_dir = path('.');
my $itr = $work_dir->iterator({recurse => 1});

while (my $file = $itr->()) {
    next unless -f $file;
    next unless $file->absolute =~ /\.tt$/;

    my $content = $file->slurp_utf8;
    while (my ($match, $stuff) = $content =~ /(\[\%\s*(.*?)\s*\%\])/ms) {
        $stuff =~ s/\.tt\b//;
        $stuff =~ s/([a-z0-9]+(?:\.[a-z0-9])+)/\$$1/g;
        $match = quotemeta $match;
        $content =~ s/$match/<: $stuff :>/
    }

    my $to_file = $file->absolute;
    $to_file =~ s/\.tt$/.tx/;
    path($to_file)->spew_utf8($content);

    $file->remove;
}

