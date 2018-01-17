#!/usr/bin/perl
#
# FileCatalog::Manifest::RegularFile.pm
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

package FileCatalog::Manifest::RegularFile;

use strict;
use warnings;

use parent 'FileCatalog::Manifest::File';

use Const::Fast;

our $VERSION = '0';

const my $CONTENT_DIGEST => q{Content-Digest};
const my $EMPTY          => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new( %args );

    $self->type( q{Regular} );

    $self->{sha256} = FileCatalog::Manifest::Field
      ->new( name => $CONTENT_DIGEST, specifier => q{SHA-256} );
    $self->{sha384} = FileCatalog::Manifest::Field
      ->new( name => $CONTENT_DIGEST, specifier => q{SHA-384} );
    $self->{sha512} = FileCatalog::Manifest::Field
      ->new( name => $CONTENT_DIGEST, specifier => q{SHA-512} );

    $self->{exact_size} = FileCatalog::Manifest::Field
      ->new( name => q{Content-Size}, specifier => q{bytes} );
    $self->{common_size} = FileCatalog::Manifest::Field
      ->new( name => q{Content-Size}, specifier => q{easy} );
    $self->{mtime_rfc2822} = FileCatalog::Manifest::Field
      ->new( name => q{Last-Modified}, specifier => q{RFC2822} );
    $self->{mtime_rfc3339} = FileCatalog::Manifest::Field
      ->new( name => q{Last-Modified}, specifier => q{RFC3339} );

    $self->{magic} = FileCatalog::Manifest::Field->new( name => q{Magic} );
    $self->{mime_type} =
      FileCatalog::Manifest::Field->new( name => q{Mime-Type} );
    $self->{encoding} =
      FileCatalog::Manifest::Field->new( name => q{Encoding} );

    $self->set_value_from_args( 'sha256', %args );
    $self->set_value_from_args( 'sha384', %args );
    $self->set_value_from_args( 'sha512', %args );
    $self->set_value_from_args( 'exact_size', %args );
    $self->set_value_from_args( 'common_size', %args );
    $self->set_value_from_args( 'mtime_rfc2822', %args );
    $self->set_value_from_args( 'mtime_rfc3339', %args );
    $self->set_value_from_args( 'magic', %args );
    $self->set_value_from_args( 'mime_type', %args );
    $self->set_value_from_args( 'emcoding', %args );

    return $self;
}

sub sha256 {
    my $self = shift;
    if (@_) { $self->{sha256}->value(shift); }
    return $self->{sha256}->value;
}

sub sha384 {
    my $self = shift;
    if (@_) { $self->{sha384}->value(shift); }
    return $self->{sha384}->value;
}

sub sha512 {
    my $self = shift;
    if (@_) { $self->{sha512}->value(shift); }
    return $self->{sha512}->value;
}

sub exact_size {
    my $self = shift;
    if (@_) { $self->{exact_size}->value(shift); }
    return $self->{exact_size}->value;
}

sub common_size {
    my $self = shift;
    if (@_) { $self->{common_size}->value(shift); }
    return $self->{common_size}->value;
}

sub mtime_rfc2822 {
    my $self = shift;
    if (@_) { $self->{mtime_rfc2822}->value(shift); }
    return $self->{mtime_rfc2822}->value;
}

sub mtime_rfc3339 {
    my $self = shift;
    if (@_) { $self->{mtime_rfc3339}->value(shift); }
    return $self->{mtime_rfc3339}->value;
}

sub magic {
    my $self = shift;
    if (@_) { $self->{magic}->value(shift); }
    return $self->{magic}->value;
}

sub mime_type {
    my $self = shift;
    if (@_) { $self->{mime_type}->value(shift); }
    return $self->{mime_type}->value;
}

sub encoding {
    my $self = shift;
    if (@_) { $self->{encoding}->value(shift); }
    return $self->{encoding}->value;
}

sub extra_info {
    my $self = shift;
    my @LINES = ();

    my $common_size = $self->{common_size}->to_string;
    my $magic = $self->{magic}->to_string;
    my $mime_type = $self->{mime_type}->to_string;
    my $encoding = $self->{encoding}->to_string;
    my $mtime_rfc2822 = $self->{mtime_rfc2822}->to_string;
    my $mtime_rfc3339 = $self->{mtime_rfc3339}->to_string;

    if( length $magic ) { push( @LINES, $magic ); }
    if( length $mime_type ) { push( @LINES, $mime_type ); }
    if( length $encoding ) { push( @LINES, $encoding ); }
    if( length $common_size ) { push( @LINES, $common_size ); }
    if( length $mtime_rfc2822 ) { push( @LINES, $mtime_rfc2822 ); }
    if( length $mtime_rfc3339 ) { push( @LINES, $mtime_rfc3339 ); }

    push( @LINES, $self->SUPER::extra_info );

    return @LINES;
}

sub as_list {
    my $self = shift;
    my @LINES = $self->SUPER::as_list;

    my $sha256 = $self->{sha256}->to_string;
    my $sha384 = $self->{sha384}->to_string;
    my $sha512 = $self->{sha512}->to_string;
    my $exact_size = $self->{exact_size}->to_string;

    if( length $sha256 ) { push( @LINES, $sha256 ); }
    if( length $sha384 ) { push( @LINES, $sha384 ); }
    if( length $sha512 ) { push( @LINES, $sha512 ); }
    if( length $exact_size ) { push( @LINES, $exact_size ); }

    return @LINES;
}

__PACKAGE__;
__END__
