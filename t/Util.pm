package t::Util;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
}
use strict;
use warnings;
use feature ':5.10';
use parent qw/Exporter/;
use Test::More 0.98 ();

use File::Spec;

use Ukigumo::Server;
use Ukigumo::Server::Launcher;

our @EXPORT = qw/test_ukigumo/;

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}

sub test_ukigumo {
    unlink 'test.db' if -f 'test.db';

    my $file = File::Spec->catfile(Ukigumo::Server->share_dir, qw/config test.pl/);
    Ukigumo::Server::Launcher->set_config($file);
    Ukigumo::Server::Launcher->setup;
    my $app = Ukigumo::Server::Launcher->to_app;

    sub {
        # XXX This guard object is sometimes sweeped unexpectedly by using `my` declaration, then using `state`.
        state $guard = t::Util::Guard->new;
        $app->(@_);
    };
}

package t::Util::Guard;

sub new {bless {}, shift};
sub DESTROY {
    unlink 'test.db';
}

1;
