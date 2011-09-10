#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.010000;
use Text::Xatena;


my $input = join '', <>;
my $thx = Text::Xatena->new;
print $thx->format($input);
