use strict;
use warnings;
use Test::More;
use Test::Requires 'Text::SimpleTable';
use File::Basename;

plan skip_all => 'this test requires "jshint" command'
  if system("jshint --version") != 0;

my @files = (<share/static/*/*.js>);

my %WHITE_LIST = map { $_ => 1 } qw(
    lang-apollo.js
    lang-clj.js
    lang-css.js
    lang-go.js
    lang-hs.js
    lang-lisp.js
    lang-lua.js
    lang-ml.js
    lang-n.js
    lang-proto.js
    lang-scala.js
    lang-sql.js
    lang-tex.js
    lang-vb.js
    lang-vhdl.js
    lang-wiki.js
    lang-xq.js
    lang-yaml.js
    prettify.js
    Chart.min.js
    jquery.powertip.min.js
    less-1.1.3.min.js
);

my $table = Text::SimpleTable->new( 25, 5 );

for my $file (@files) {
    next if $WHITE_LIST{basename($file)};
    next if basename($file) =~ /jquery-[0-9.]+.min.js$/;

    my $out = `jshint $file`;
    my $err = 0;
    if ( $out =~ /(\d+) errors?/ ) {
        ( $err ) = ( $1 );
        is($err, 0, $file)
            or note $out;
    }
    else {
        ok(1);
    }
    $table->row( basename($file), $err );
}

note $table->draw;

done_testing;
