#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Locale::Maketext::Extract;
use File::Find::Rule;
use Template; # for parsing TT

my $Ext = Locale::Maketext::Extract->new(
    # Specify which parser plugins to use
    plugins => {
        # Use Perl parser, process files with extension .pl .pm .cgi
        perl => [qw/pl pm js/],

        # Use TT2 parser, process files with extension .tt2 .tt .html
        # or which match the regex
        tt2  => [
            'tt',
        ],
    },

    # Warn if a parser can't process a file
    warnings => 1,

    # List processed files
    verbose => 1,
);
for my $lang (qw/ja/) {
    $Ext->read_po("po/$lang.po") if -f "po/$lang.po";
    $Ext->extract_file($_) for File::Find::Rule->file()->name('*.pm')->in('lib');
    $Ext->extract_file($_) for File::Find::Rule->file()->name('*.tt')->in('tmpl/');

    # Set $entries_are_in_gettext_format if the .pl files above use
    # loc('%1') instead of loc('[_1]')
    $Ext->compile(1);

    $Ext->write_po("po/$lang.po");
}
