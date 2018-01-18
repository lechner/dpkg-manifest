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
use Manifest::Field::SizeInBytes;
use Manifest::Field::AnnotatedBinary;

use parent 'Manifest::Item::File';

our $VERSION = '0';

const my $CONTENT_DIGEST => q{Content-Digest};
const my $EMPTY          => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->type(q{Regular});

    $self->{sha256} = Manifest::Field::AnnotatedBinary->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-256}
    );
    $self->{sha384} = Manifest::Field::AnnotatedBinary->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-384}
    );
    $self->{sha512} = Manifest::Field::AnnotatedBinary->new(
        label      => $CONTENT_DIGEST,
        note => q{SHA-512}
    );

    $self->{exact_size} = Manifest::Field::SizeInBytes->new(
        label      => q{Content-Size},
    );
    $self->{common_size} = Manifest::Field::AnnotatedText->new(
        label      => q{Content-Size},
        note => q{easy}
    );
    $self->{mtime} = Manifest::Field::Date->new(label => q{Last-Modified} );

    $self->{magic} = Manifest::Field::Text->new( label => q{Magic} );
    $self->{mime_type} = Manifest::Field::Text->new( label => q{Mime-Type} );
    $self->{encoding} = Manifest::Field::Text->new( label => q{Encoding} );

#    $self->set_value_from_args( 'sha256',        %args );
#    $self->set_value_from_args( 'sha384',        %args );
#    $self->set_value_from_args( 'sha512',        %args );
#    $self->set_value_from_args( 'exact_size',    %args );
    $self->set_value_from_args( 'common_size',   %args );
    $self->set_value_from_args( 'mtime',         %args );
    $self->set_value_from_args( 'magic',         %args );
    $self->set_value_from_args( 'mime_type',     %args );
    $self->set_value_from_args( 'emcoding',      %args );

    return $self;
}

sub sha256 {
    my $self = shift;
    if (@_) { $self->{sha256}->binary(shift); }
    return $self->{sha256}->text;
}

sub sha384 {
    my $self = shift;
    if (@_) { $self->{sha384}->binary(shift); }
    return $self->{sha384}->text;
}

sub sha512 {
    my $self = shift;
    if (@_) { $self->{sha512}->binary(shift); }
    return $self->{sha512}->text;
}

sub exact_size {
    my $self = shift;
    if (@_) { $self->{exact_size}->bytes(shift); }
    return $self->{exact_size}->bytes;
}

sub common_size {
    my $self = shift;
    if (@_) { $self->{common_size}->text(shift); }
    return $self->{common_size}->text;
}

sub mtime {
    my $self = shift;
    if (@_) { $self->{mtime}->date_time(shift); }
    return $self->{mtime}->date_time;
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

    push @LINES, $self->{common_size}->as_list;
    push @LINES, $self->{magic}->as_list;
    push @LINES, $self->{mime_type}->as_list;
    push @LINES, $self->{encoding}->as_list;
    push @LINES, $self->{mtime}->as_list;

    push @LINES, $self->SUPER::extra_info;

    return @LINES;
}

sub as_list {
    my $self  = shift;
    my @LINES = $self->SUPER::as_list;

    push @LINES, $self->{sha256}->as_list;
    push @LINES, $self->{sha384}->as_list;
    push @LINES, $self->{sha512}->as_list;
    push @LINES, $self->{exact_size}->as_list;

    return @LINES;
}

__PACKAGE__;
__END__
