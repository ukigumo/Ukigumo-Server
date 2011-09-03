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
use Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like', 'Ukigumo::Helper' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
        },
        %$view_conf
    });
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

1;
