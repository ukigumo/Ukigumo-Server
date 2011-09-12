use strict;
use warnings;
use utf8;
use Test::More;
use Ukigumo::Server::Command::Docs;
use Ukigumo::Server;

my $c = Ukigumo::Server->bootstrap;

my $html = Ukigumo::Server::Command::Docs->render('about');
like $html, qr{<h1>};
like $html, qr{<pre class="prettyprint">};
note $html;

done_testing;

