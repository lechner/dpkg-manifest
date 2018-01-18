#!/usr/bin/perl
#
# Manifest::Item::RegularFile.pm
#
# Copyright © 2018 Felix Lechner <felix.lechner@lease-up.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package Manifest::Item::RegularFile;

use strict;
use warnings;
use Const::Fast;

use parent 'Manifest::Item::File';

our $VERSION = '0';

const my $CONTENT_DIGEST => q{Content-Digest};
const my $EMPTY          => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->type(q{Regular});

    $self->{sha256} = Manifest::Field::AnnotatedText->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-256}
    );
    $self->{sha384} = Manifest::Field::AnnotatedText->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-384}
    );
    $self->{sha512} = Manifest::Field::AnnotatedText->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-512}
    );

    $self->{exact_size} = Manifest::Field::AnnotatedText->new(
        label      => q{Content-Size},
        note => q{bytes}
    );
    $self->{common_size} = Manifest::Field::AnnotatedText->new(
        label      => q{Content-Size},
        note => q{easy}
    );
    $self->{mtime_rfc2822} = Manifest::Field::AnnotatedText->new(
        label      => q{Last-Modified},
        note => q{RFC2822}
    );
    $self->{mtime_rfc3339} = Manifest::Field::AnnotatedText->new(
        label      => q{Last-Modified},
        note => q{RFC3339}
    );

    $self->{magic} = Manifest::Field::Text->new( label => q{Magic} );
    $self->{mime_type} = Manifest::Field::Text->new( label => q{Mime-Type} );
    $self->{encoding} = Manifest::Field::Text->new( label => q{Encoding} );

    $self->set_value_from_args( 'sha256',        %args );
    $self->set_value_from_args( 'sha384',        %args );
    $self->set_value_from_args( 'sha512',        %args );
    $self->set_value_from_args( 'exact_size',    %args );
    $self->set_value_from_args( 'common_size',   %args );
    $self->set_value_from_args( 'mtime_rfc2822', %args );
    $self->set_value_from_args( 'mtime_rfc3339', %args );
    $self->set_value_from_args( 'magic',         %args );
    $self->set_value_from_args( 'mime_type',     %args );
    $self->set_value_from_args( 'emcoding',      %args );

    return $self;
}

sub sha256 {
    my $self = shift;
    if (@_) { $self->{sha256}->text(shift); }
    return $self->{sha256}->text;
}

sub sha384 {
    my $self = shift;
    if (@_) { $self->{sha384}->text(shift); }
    return $self->{sha384}->text;
}

sub sha512 {
    my $self = shift;
    if (@_) { $self->{sha512}->text(shift); }
    return $self->{sha512}->text;
}

sub exact_size {
    my $self = shift;
    if (@_) { $self->{exact_size}->text(shift); }
    return $self->{exact_size}->text;
}

sub common_size {
    my $self = shift;
    if (@_) { $self->{common_size}->text(shift); }
    return $self->{common_size}->text;
}

sub mtime_rfc2822 {
    my $self = shift;
    if (@_) { $self->{mtime_rfc2822}->text(shift); }
    return $self->{mtime_rfc2822}->text;
}

sub mtime_rfc3339 {
    my $self = shift;
    if (@_) { $self->{mtime_rfc3339}->text(shift); }
    return $self->{mtime_rfc3339}->text;
}

sub magic {
    my $self = shift;
    if (@_) { $self->{magic}->text(shift); }
    return $self->{magic}->text;
}

sub mime_type {
    my $self = shift;
    if (@_) { $self->{mime_type}->text(shift); }
    return $self->{mime_type}->text;
}

sub encoding {
    my $self = shift;
    if (@_) { $self->{encoding}->text(shift); }
    return $self->{encoding}->text;
}

sub extra_info {
    my $self  = shift;
    my @LINES = ();

    my $common_size   = $self->{common_size}->to_string;
    my $magic         = $self->{magic}->to_string;
    my $mime_type     = $self->{mime_type}->to_string;
    my $encoding      = $self->{encoding}->to_string;
    my $mtime_rfc2822 = $self->{mtime_rfc2822}->to_string;
    my $mtime_rfc3339 = $self->{mtime_rfc3339}->to_string;

    if ( length $magic )         { push @LINES, $magic; }
    if ( length $mime_type )     { push @LINES, $mime_type; }
    if ( length $encoding )      { push @LINES, $encoding; }
    if ( length $common_size )   { push @LINES, $common_size; }
    if ( length $mtime_rfc2822 ) { push @LINES, $mtime_rfc2822; }
    if ( length $mtime_rfc3339 ) { push @LINES, $mtime_rfc3339; }

    push @LINES, $self->SUPER::extra_info;

    return @LINES;
}

sub as_list {
    my $self  = shift;
    my @LINES = $self->SUPER::as_list;

    my $sha256     = $self->{sha256}->to_string;
    my $sha384     = $self->{sha384}->to_string;
    my $sha512     = $self->{sha512}->to_string;
    my $exact_size = $self->{exact_size}->to_string;

    if ( length $sha256 )     { push @LINES, $sha256; }
    if ( length $sha384 )     { push @LINES, $sha384; }
    if ( length $sha512 )     { push @LINES, $sha512; }
    if ( length $exact_size ) { push @LINES, $exact_size; }

    return @LINES;
}

__PACKAGE__;
__END__
