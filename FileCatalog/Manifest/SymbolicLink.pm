#!/usr/bin/perl
#
# FileCatalog::Manifest::SymbolicLink.pm
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

package FileCatalog::Manifest::SymbolicLink;

use strict;
use warnings;

use parent 'FileCatalog::Manifest::File';

use Const::Fast;

our $VERSION = '0';
const my $EMPTY => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new( %args );

    $self->type( q{Link} );

    $self->{destination} = FileCatalog::Manifest::Field
      ->new( name => q{Destination} );

    $self->set_value_from_args( 'destination', %args);

    return $self;
}

sub destination {
    my $self = shift;
    if (@_) { $self->{destination}->value( shift ); }
    return $self->{destination}->value;
}

sub as_list {
    my $self = shift;
    my @LINES = $self->SUPER::as_list;

    my $destination = $self->{destination}->to_string;
    if( length $destination ) { push( @LINES, $destination ); }

    return @LINES;
}

__PACKAGE__;
__END__
