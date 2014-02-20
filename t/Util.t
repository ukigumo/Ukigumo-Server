use strict;
use warnings;
use utf8;
use Test::More;

use Ukigumo::Server::Util;

my $code = <<'END_OF_THE_WORLD';
XXX
YYY>
END_OF_THE_WORLD

my $re = <<'END_OF_RE';
<a href="#L1" id="L1" class="line-anchor">_</a>&nbsp;<span><span class="">XXX</span></span>
<a href="#L2" id="L2" class="line-anchor">_</a>&nbsp;<span><span class="">YYY&gt;</span></span>
END_OF_RE

like(Ukigumo::Server::Util::make_line_link($code), qr{$re});

done_testing;

