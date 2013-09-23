package Ukigumo::Server::L10N;
use strict;
use warnings;
use utf8;
use parent 'Locale::Maketext';
use File::Spec;
use Locale::Maketext::Lexicon + {
    ja => [ Gettext => File::Spec->catdir( Ukigumo::Server->share_dir(), 'po', 'ja.po' ) ],
    en => ['Auto'], # ソース言語はそのままだす
    _preload => 1,
    _auto    => $ENV{UKIGUMO_DEBUG_L10N} ? 0 : 1,
    _style   => 'gettext',
    _decode  => 1,                          # decode characters to utf8 flagged.
};

1;

