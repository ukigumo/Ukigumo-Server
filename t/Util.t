use strict;
use warnings;
use utf8;
use Test::More;

use Ukigumo::Server::Util;

is(Ukigumo::Server::Util::make_line_link(<<'...'), <<',,,');
XXX
YYY>
...
<a href="#L1" id="L1" class="line-anchor">_</a>&nbsp;<span>XXX</span>
<a href="#L2" id="L2" class="line-anchor">_</a>&nbsp;<span>YYY&gt;</span>
,,,

done_testing;

