package Ukigumo::Server::Web::ViewFunctions;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);
use URI::WithBase;
use Text::Xslate qw/mark_raw html_escape/;
use Module::Functions;
use POSIX::strftime::Compiler qw/strftime/;
use Time::Duration::Abbreviated ();
use Ukigumo::Constants;

our @EXPORT = get_public_functions();

sub c { Amon2->context() }
sub uri_with { Amon2->context()->req->uri_with(@_) }
sub uri_for { Amon2->context()->uri_for(@_) }

sub abs_uri_for {
    my $c = Amon2->context();
    URI::WithBase->new($c->uri_for(@_), $c->req->base)->abs;
}

sub lang {
    Amon2->context->lang
}

sub ago {
    Amon2->context->duration->can('ago')->(@_)
}

sub duration {
    my $sec = shift;

    return '-' unless defined $sec;
    Time::Duration::Abbreviated::duration($sec, 3);
}

sub l {
    my $base = shift;
    my @args = map { html_escape $_ } @_;    # escape arguments
    mark_raw( Amon2->context->loc( $base, @args ) );
}

sub ctime_cc_str {
    my $epoch = shift;
    strftime('%Y-%m-%dT%H:%M:%S.000%z', localtime $epoch);
}

sub status_cc_str {
    my $status = shift;
    +{
        STATUS_SUCCESS() => 'Success',
        STATUS_FAIL()    => 'Failure',
        STATUS_TIMEOUT() => 'Timeout',
        STATUS_NA()      => 'Unknown',
        STATUS_SKIP()    => 'Unknown',
    }->{$status} || 'Unknown';
}

1;

