use strict;
use warnings;
use utf8;

package Ukigumo::Server::Util;
use Text::Xslate::Util qw(html_escape mark_raw);
use HTML::FromANSI::Tiny;

my $ansi = HTML::FromANSI::Tiny->new(
    auto_reverse => 1, background => 'white', foreground => 'black',
);

# 行頭に行ごとのリンクをつけるの術
sub make_line_link {
    my $src = shift;

    my @lines = split /\r?\n/, $src;
    my $num = 1;
    my $html = $ansi->style_tag;
    for my $line (@lines) {
        $html .= qq{<a href="#L$num" id="L$num" class="line-anchor">_</a>&nbsp;<span>};
        $html .= $ansi->html($line) . "</span>\n";
        $num++;
    }
    return mark_raw($html);
}

1;

