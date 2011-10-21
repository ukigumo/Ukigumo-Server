package Ukigumo::Server::Web;
use strict;
use warnings;
use parent qw/Ukigumo::Server Amon2::Web/;
use File::Spec;

# dispatcher
use Ukigumo::Server::Web::Dispatcher;
sub dispatch {
	my $c = shift;
    return Ukigumo::Server::Web::Dispatcher->dispatch($c)
      or die "response is not generated";
}

# setup view class
use Text::Xslate qw/mark_raw html_escape/;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl') ];
    }
    my $view = Text::Xslate->new(
        +{
            'syntax' => 'TTerse',
            'module' => [ 'Text::Xslate::Bridge::TT2Like', 'Ukigumo::Helper' ],
            'function' => {
                c        => sub { Amon2->context() },
                uri_with => sub { Amon2->context()->req->uri_with(@_) },
                uri_for  => sub { Amon2->context()->uri_for(@_) },
                lang     => sub {
                    Amon2->context->lang
                },
                ago => sub {
                    Amon2->context->duration->can('ago')->(@_)
                },
                l        => sub {
                    my $base = shift;
                    my @args = map { html_escape $_ } @_;    # escape arguments
                    mark_raw( Amon2->context->loc( $base, @args ) );
                },
            },
            %$view_conf
        }
    );
    sub create_view { $view }
}

__PACKAGE__->load_plugins(
	'Web::JSON',
	'Web::PlackSession',
	'Web::CSRFDefender',
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

use Ukigumo::Server::L10N;

sub loc { shift->l10n->maketext(@_) }

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my $c = shift;

        if ( my $lang = $c->req->param('lang') ) {
            return $c->show_error("Unknown language: $lang")
              if $lang !~ /^(?:en|ja)$/;
            $c->session->set( lang => $lang );
        }

        return undef;
    },
);

{
    my %langs = (
        ja => Ukigumo::Server::L10N->get_handle('ja'),
        en => Ukigumo::Server::L10N->get_handle('en'),
    );

    sub lang {
        my ($c) = @_;
        return 'ja' if ( $c->session->get('lang') || 'en' ) eq 'ja';
        return 'ja' if ( $c->req->param('lang')   || 'en' ) eq 'ja';
        return 'en' if ( $c->req->header('Accept-Language') || 'ja' ) =~ /en/;
        return 'en';
    }

    sub l10n {
        my ($c) = @_;
        return $langs{ $c->lang };
    }

    use Time::Duration;
    use Time::Duration::ja;
    sub duration {
        shift->lang eq 'ja' ? 'Time::Duration::ja' : 'Time::Duration';
    }
}



1;
