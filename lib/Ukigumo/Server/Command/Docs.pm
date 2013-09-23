use strict;
use warnings;
use utf8;

package Ukigumo::Server::Command::Docs;
use Text::Markdown;
use Amon2::Declare;
use Text::Xslate::Util qw(mark_raw);

sub render {
    my ($class, $path) = @_;
    $path // die "Missing mandatory parameter: path";
    my $c = c();

    my $src = do {
        my $fname = File::Spec->catfile($c->share_dir, "docs/$path.txt");
        open my $fh, '<:encoding(utf-8)', $fname or die "Cannot open file: $fname: $!";
        do { local $/; <$fh> };
    };
    $src =~ s{^#include "([^"]+)"}{
        my $fname = File::Spec->catfile($c->share_dir, $1);
        open my $fh, '<:utf8', $fname or die "Cannot open file: $fname: $!";
        "\n\n" . do { join '', map { "    $_" } <$fh> } . "\n\n";
    }mge;
    my $tnx = Text::Markdown->new();
    my $doc = $tnx->markdown($src);
    $doc =~ s/<pre><code>/<pre class="prettyprint"><code>/g;
    mark_raw($doc);
}

1;

