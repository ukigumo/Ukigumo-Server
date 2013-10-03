#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Locale::Maketext::Extract;
use Locale::Maketext::Extract::Plugin::Xslate;
use File::Find::Rule;

my $Ext = Locale::Maketext::Extract->new(
    plugins => {
        perl => [qw/pl pm js/],
        xslate => {
            syntax => 'Kolon',
        },
    },
    warnings => 1,
    verbose => 1,
);
for my $lang (qw/ja/) {
    $Ext->read_po("share/po/$lang.po") if -f "share/po/$lang.po";
    $Ext->extract_file($_) for File::Find::Rule->file()->name('*.pm')->in('lib');
    $Ext->extract_file($_) for File::Find::Rule->file()->name('*.tx')->in('share/tmpl/');

    # Set $entries_are_in_gettext_format if the .pl files above use
    # loc('%1') instead of loc('[_1]')
    $Ext->compile(1);

    $Ext->write_po("share/po/$lang.po");
}
