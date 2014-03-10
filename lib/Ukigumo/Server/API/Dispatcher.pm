use strict;
use warnings;
use utf8;
use 5.0100000;

package Ukigumo::Server::API::Dispatcher;
use Router::Simple;
use Data::Validator;

my $router = Router::Simple->new();

sub rule { Ukigumo::Server::Validator->new(@_) }
sub post {
    my ($path, $rule_src, $code) = @_;
    my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
    $router->connect($path, +{ code => $code, rule => $rule }, {method => 'POST'})
}
sub get {
    my ($path, $rule_src, $code) = @_;
    my $rule = Data::Validator->new(@$rule_src)->with('NoThrow');
    $router->connect($path, +{ code => $code, rule => $rule }, {method => 'GET'})
}

get '/api/v1/branch/list' => [
    project  => { isa => 'Str' },
] => sub {
    my ($c, $args) = @_;

    return +{
        branches => scalar(Ukigumo::Server::Command::Branch->list(
            %$args
        ))
    };
};

post '/api/v1/branch/delete' => [
    project  => { isa => 'Str' },
    branch   => { isa => 'Str' },
] => sub {
    my ($c, $args) = @_;

    my $branch_id = Ukigumo::Server::Command::Branch->find(
        %$args
    );
    Ukigumo::Server::Command::Branch->delete(
        branch_id => $branch_id
    );

    return { };
};

get '/api/v1/report/search' => [
    project  => { isa => 'Str' },
    branch   => { isa => 'Str' },
    revision => { isa => 'Str' },
    limit    => { isa => 'Int', default => 20 },
] => sub {
    my ($c, $args) = @_;

    # and insert it
    my $reports = Ukigumo::Server::Command::Report->search(
        %$args
    );

    return {
        reports => +[
            map { +{
                report_id => $_->{report_id},
                status    => $_->{status},
                ctime     => $_->{ctime},
            } } @$reports
        ]
    };
};

post '/api/v1/report/add' => [
    status   => { isa => 'Int' },
    project  => { isa => 'Str' },
    branch   => { isa => 'Str' },
    vc_log   => { isa => 'Str', optional => 1 },
    body     => { isa => 'Str', optional => 1 },
    revision => { isa => 'Str' },
    repo     => { isa => 'Str' },
    compare_url => { isa => 'Str', optional => 1 }
] => sub {
    my ($c, $args) = @_;

    my $body;
    if (my $upload = $c->req->upload('body')) {
        my $fname = $upload->path;
        open my $fh, '<:encoding(utf-8)', $fname or die "Cannot open file: $fname: $!";
        $body = do { local $/; <$fh> };
    }

    # get last report status
    my $last_status = Ukigumo::Server::Command::Report->get_last_status(
        project => $args->{project},
        branch  => $args->{branch}
    );

    # and insert it
    my $report_id = Ukigumo::Server::Command::Report->insert(
        (defined $body ? (body => $body) : () ),
        %$args
    );
    my $url = Ukigumo::Server::Command::Report->get_url($report_id);

    return {
        report => +{
            report_id   => $report_id,
            url         => $url,
            last_status => $last_status,
        }
    };
};

sub dispatch {
    my ($class, $c) = @_;

    if (my $controller = $router->match($c->req->env)) {
        my $rule = $controller->{rule} or die;
        my $args = $rule->validate($c->req->parameters->flatten);
        if ($rule->has_errors) {
            my $errors = $rule->clear_errors;
            my $message = join("\n", map { $_->{message} } @$errors);
            my $res = $c->render_json( +{ error => +{ message => $message } } );
            $res->code(400);
            return $res;
        }
        my $res = $controller->{code}->($c, $args);
        if (ref $res eq 'HASH') {
            return $c->render_json($res); # succeeded
        } else {
            return $res; # succeeded
        }
    } else {
        return $c->res_404(); # not found...
    }
}

1;

