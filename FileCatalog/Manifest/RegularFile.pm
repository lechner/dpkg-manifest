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

    $self->type( q{Regular-File} );

    if ( exists $args{path} ) { $self->path( $args{path} ); }

    $self->{sha256} = FileCatalog::Manifest::Field->new(
        name      => $CONTENT_DIGEST,
        specifier => q{SHA-256}
    );
    $self->{sha384} = FileCatalog::Manifest::Field->new(
        name      => $CONTENT_DIGEST,
        specifier => q{SHA-384}
    );
    $self->{sha512} = FileCatalog::Manifest::Field->new(
        name      => $CONTENT_DIGEST,
        specifier => q{SHA-512}
    );

    if ( exists $args{sha256} ) { $self->sha256( $args{sha256} ); }
    if ( exists $args{sha384} ) { $self->sha384( $args{sha384} ); }
    if ( exists $args{sha512} ) { $self->sha512( $args{sha512} ); }

    $self->{size} =
      FileCatalog::Manifest::Field->new( name => q{Content-Size} );

    if ( exists $args{size} ) { $self->{size}->value( $args{size} ); }

    $self->{magic} = FileCatalog::Manifest::Field->new( name => q{Magic} );
    $self->{mime_type} =
      FileCatalog::Manifest::Field->new( name => q{Mime-Type} );
    $self->{encoding} =
      FileCatalog::Manifest::Field->new( name => q{Encoding} );

    if ( exists $args{magic} )     { $self->magic( $args{magic} ); }
    if ( exists $args{mime_type} ) { $self->mime_type( $args{mime_type} ); }
    if ( exists $args{encoding} )  { $self->encoding( $args{encoding} ); }

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

sub size {
    my $self = shift;
    if (@_) { $self->{size}->value(shift); }
    return $self->{size}->value;
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
    return
        $self->SUPER::extra_info
      . $self->{magic}->to_string
      . $self->{mime_type}->to_string
      . $self->{encoding}->to_string
      . $self->{size}->to_string;
}

sub to_string {
    my $self = shift;
    return
        $self->SUPER::to_string
      . $self->{sha256}->to_string
      . $self->{sha384}->to_string
      . $self->{sha512}->to_string;
}

sub print {
    my $self = shift;
    print $self->to_string;
}

__PACKAGE__;
__END__
