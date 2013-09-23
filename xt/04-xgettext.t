use strict;
use warnings;
use utf8;
use Test::More;
use autodie;

system("$^X author/xgettext.pl");
open my $fh, '<', 'share/po/ja.po';
my $src = do { local $/; <$fh> };
like($src, qr{Ukigumo});

done_testing;

