package Ukigumo::Server::API;
use strict;
use warnings;
use parent qw/Ukigumo::Server::Container Amon2::Web/;
use File::Spec;

# dispatcher
use Ukigumo::Server::APIDispatcher;

sub dispatch {
	my $c = shift;
    return Ukigumo::Server::APIDispatcher->dispatch($c) or die "response is not generated";
}

__PACKAGE__->load_plugins( 'Web::JSON' );

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;
