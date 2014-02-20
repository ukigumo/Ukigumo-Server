use strict;
use warnings;
use utf8;
use Test::More;

use Ukigumo::Server::Util;

like(Ukigumo::Server::Util::make_line_link(<<'...'), qr{@{[ <<',,,' ]}});
XXX
YYY>
...
<a href="#L1" id="L1" class="line-anchor">_</a>&nbsp;<span><span class="">XXX</span></span>
<a href="#L2" id="L2" class="line-anchor">_</a>&nbsp;<span><span class="">YYY&gt;</span></span>
,,,

done_testing;

