package Film::Model::Row::Page;

use strict;
use warnings;
use base 'DBIx::Skinny::Row';

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

sub history {
	my $history = Film::Model->select(q{
		SELECT * FROM page_history
		ORDER BY created_at DESC
		LIMIT 50
	});
}

sub save_history {
	my ($self) = @_;

	Film::Model->insert('page_history', {
		page_id => $self->id,
		body    => $self->body
	});
}

sub path {
	my ($self, $ext) = @_;
	sprintf('/%s%s', uri_escape($self->title), $ext);
}

1;
__END__



