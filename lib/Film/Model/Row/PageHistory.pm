package Film::Model::Row::PageHistory;

use strict;
use warnings;
use base qw(DBIx::Skinny::Row Film::Model::Row::Page);

use URI::Escape;
use Text::Xatena;
use Text::Xatena::Inline::Aggressive;
use Cache::FileCache;

sub formatted_body {
	my ($self) = @_;
	Text::Xatena->new->format($self->body,
		inline => Text::Xatena::Inline::Aggressive->new(
			cache => Cache::FileCache->new({default_expires_in => 60 * 60 * 24 * 30})
		)
	);
}

sub page {
	my ($self) = @_;
	my $page  = Film::Model->single('page', { id => $self->page_id });
}

sub title {
	my ($self) = @_;
	$self->page->title;
}

1;
__END__



