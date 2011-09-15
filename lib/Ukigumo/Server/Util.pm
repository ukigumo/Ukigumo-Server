use strict;
use warnings;
use utf8;

package Ukigumo::Server::Util;
use Text::Xslate::Util qw(html_escape mark_raw);

# 行頭に行ごとのリンクをつけるの術
sub make_line_link {
    my $src = shift;
    my @lines = map { html_escape($_) } split /\r?\n/, $src;
    my $num = 1;
    my $html = '';
    for my $line (@lines) {
        $html .= qq{<a href="#L$num" id="L$num" class="line-anchor">_</a>&nbsp;<span>};
        $html .= html_escape($line) . "</span>\n";
        $num++;
    }
    return mark_raw($html);
}

1;

