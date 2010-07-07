package Film;

use strict;
use warnings;

use URI::Escape;

use Film::Router;
use Film::Config;
use Film::Model;
use Film::Request;
use Film::Response;
use Film::View;
use Film::Empty;

route '/', action => sub {
	my ($r) = @_;
	my $title = 'FrontPage';
	$r->html('page.html');
};

route '/:title.edit', method => GET, action => sub {
	my ($r) = @_;
	my $title = $r->req->param('title');
	my $page  = Film::Model->single('page', { title => $title }) || Film::Empty->new;
	$r->stash(page => $page);
	$r->html('edit.html');
};
route '/:title.edit', method => POST, action => sub {
	my ($r) = @_;
	my $title = $r->req->param('title');
	my $body  = $r->req->param('body');
	my $page  = Film::Model->single('page', { title => $title });
	if ($page) {
		if ($page->body ne $body) {
			$page->save_history;
			$page->set({
				body => $body
			});
			$page->update;
		}
	} else {
		$page = Film::Model->insert('page', {
			title => $r->req->param('title'),
			body  => $body,
		});
	}
	$r->res->redirect($page->path);
};

route '/:title', action => sub {
	my ($r) = @_;
	my $title   = $r->req->param('title');
	my $history = $r->req->param('history');
	my $page  = Film::Model->single('page', { title => $title }) or return $r->res->code(400);

	if ($history) {
		my $page_history = Film::Model->single('page_history', {
			id      => $history,
			page_id => $page->id,
		}) or return $r->res->redirect($page->path);

		$page = $page_history;
	}

	$r->stash(page => $page);
	$r->html('page.html');
};

sub uri_for {
	my ($r, $path, $args) = @_;
	$path ||= "";
	my $uri = $r->req->base;
	$uri->path(($r->config->{_}->{root} || $uri->path) . $path);
	$uri->query_form(@$args) if $args;
	$uri;
}

sub abs_uri {
	my ($r, $path, $args) = @_;
	$path ||= "";
	my $uri = URI->new($r->config->{_}->{base});
	$uri->path(($r->config->{_}->{root} || $uri->path) . $path);
	$uri->query_form(@$args) if $args;
	$uri;
}

# static methods

sub run {
	my ($env) = @_;
	my $req = Film::Request->new($env);
	my $res = Film::Response->new;
	my $niro = Film->new(
		req => $req,
		res => $res,
	);
	$niro->_run;
}

sub new {
	my ($class, %opts) = @_;
	bless {
		%opts
	}, $class;
}

sub config {
	Film::Config->instance;
}

sub _run {
	my ($self) = @_;
	Film::Router->dispatch($self);
	$self->res->finalize;
}

sub req { $_[0]->{req} }
sub res { $_[0]->{res} }
sub log {
	my ($class, $format, @rest) = @_;
	print STDERR sprintf($format, @rest) . "\n";
}

sub stash {
	my ($self, %params) = @_;
	$self->{stash} = {
		%{ $self->{stash} || {} },
		%params
	};
	$self->{stash};
}

sub error {
	my ($self, %opts) = @_;
	$self->res->status($opts{code} || 500);
	$self->res->body($opts{message} || $opts{code} || 500);
}


my $db = Film::Config->instance->root->file(($ENV{HTTP_HOST} || "") =~ /\blab\b/ ? 'pages-test.db' : 'pages.db');
Film::Model->connect_info({
	dsn => 'dbi:SQLite:' . $db,
});
unless (-f $db) {
	Film::Model->do($_) for split /;/, do {
		my $schema = Film->config->root->file('db', 'schema.sql')->slurp;
		$schema =~ s/;\s*$//;
		$schema;
	};
}

1;
__END__





