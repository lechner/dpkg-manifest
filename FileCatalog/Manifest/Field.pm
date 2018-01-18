#!/usr/bin/perl
#
# FileCatalog::Manifest::Field.pm
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

package FileCatalog::Manifest::Field;

use strict;
use warnings;
use Const::Fast;

our $VERSION = '0';

const my $EMPTY => q{};
const my $SPACE => q{ };
const my $COLON => q{:};
const my $LEFT_SQUARE => q{[};
const my $RIGHT_SQUARE => q{]};
const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;

    my $self = bless( {}, $class );

    $self->name( exists $args{name}           ? $args{name}      : $EMPTY );
    $self->value( exists $args{value}         ? $args{value}     : $EMPTY );
    $self->specifier( exists $args{specifier} ? $args{specifier} : $EMPTY );

    return $self;
}

sub set_value_from_args {
  my $self = shift;
  my ($key, %elsewhere) = @_;

  if( exists $elsewhere{$key} ) {
    $self->value( $elsewhere{$key} );
  }
}

sub name {
    my $self = shift;
    if (@_) { $self->{name} = shift; }
    return $self->{name};
}

sub value {
    my $self = shift;
    if (@_) { $self->{value} = shift; }
    return $self->{value};
}

sub specifier {
    my $self = shift;
    if (@_) { $self->{specifier} = shift; }
    return $self->{specifier};
}

sub to_string {
    my $self = shift;
    if(length $self->value ) {
      return $self->name . $COLON . $SPACE
        . ( $self->specifier
            ? $LEFT_SQUARE . $self->specifier . $RIGHT_SQUARE . $SPACE
            : $EMPTY )
        . $self->value;
    }
    return $EMPTY;
}

sub print {
    my $self = shift;
    print $self->to_string . $NEWLINE;
}

__PACKAGE__;
__END__
