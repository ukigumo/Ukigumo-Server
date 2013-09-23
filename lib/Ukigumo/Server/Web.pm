package Ukigumo::Server::Web;
use strict;
use warnings;
use feature ':5.10';
use parent qw/Ukigumo::Server Amon2::Web/;
use File::Spec;

use Ukigumo::Constants;

# dispatcher
use Ukigumo::Server::Web::Dispatcher;
sub dispatch {
    my $c = shift;
    return Ukigumo::Server::Web::Dispatcher->dispatch($c)
      or die "response is not generated";
}

# setup view class
sub create_view {
    state $view = do {
        my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
        unless (exists $view_conf->{path}) {
            $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->share_dir(), 'tmpl') ];
        }
        Text::Xslate->new(
            +{
                'syntax' => 'TTerse',
                'module' => [ 'Text::Xslate::Bridge::TT2Like', 'Ukigumo::Helper', 'Text::Xslate::Bridge::Star', 'Ukigumo::Server::Web::ViewFunctions' ],
                %$view_conf
            }
        );
    };
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

    use Time::Duration ();
    use Time::Duration::ja ();
    sub duration {
        shift->lang eq 'ja' ? 'Time::Duration::ja' : 'Time::Duration';
    }
}



1;
