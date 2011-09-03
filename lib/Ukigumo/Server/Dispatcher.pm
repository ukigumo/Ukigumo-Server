package Ukigumo::Server::Dispatcher;
use strict;
use warnings;
use 5.010001;
use Amon2::Web::Dispatcher::Lite;
use SQL::Interp qw(:all);
use URI::Escape qw(uri_unescape);
use Time::Piece;
use Ukigumo::Server::Command::Report;
use Ukigumo::Server::Command::Branch;
use Data::Validator;

any '/' => sub {
    my ($c) = @_;

    my %where;
    if (my $project = $c->req->param('project')) {
        $where{project} = $project;
    }
    my $projects = Ukigumo::Server::Command::Branch->list(%where);

    $c->render( 'index.tt', { projects => $projects, now => time() } );
};

get '/project/{project}/{branch}' => sub {
    my ($c, $args) = @_;
    my $project = $args->{project};
    my $branch = $args->{branch};

    my $reports = Ukigumo::Server::Command::Report->list(
        project => $project,
        branch  => $branch,
        limit   => 50,
    );
    return $c->render(
        'report_list.tt' => {
            project => $project,
            branch  => $branch,
            reports => $reports,
        }
    );
};

get '/branch/delete' => sub {
    my ($c, $args) = @_;

    my $branch_id = $c->req->param('branch_id') || die;
    my $branch = Ukigumo::Server::Command::Branch->lookup(
        branch_id => $branch_id,
    );
    return $c->render(
        'branch_delete.tt' => {
            branch  => $branch,
        }
    );
};
post '/branch/delete' => sub {
    my ($c, $args) = @_;

    my $branch_id = $c->req->param('branch_id') || die;
    Ukigumo::Server::Command::Branch->delete(
        branch_id => $args->{branch_id},
    );
    return $c->redirect('/');
};

get '/report/{report_id:\d+}' => sub {
    my ($c, $args) = @_;
    my $report_id = $args->{report_id};
    my $report = Ukigumo::Server::Command::Report->find( report_id => $report_id );
    if ($report) {
        return $c->render('show_report.tt', {report => $report});
    } else {
        return $c->res_404();
    }
};


1;
