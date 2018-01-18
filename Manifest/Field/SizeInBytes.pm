#!/usr/bin/perl
#
# Manifest::Field::SizeInBytes.pm
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

package Manifest::Field::SizeInBytes;

use strict;
use warnings;
use feature qw(switch);
no if $] >= 5.018, warnings => 'experimental::smartmatch';

use Const::Fast;
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;

use parent 'Manifest::Field::Text';

our $VERSION = '0';

const my $EMPTY        => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->set_from_args( 'bytes', %args );
    return $self;
}

sub bytes {
    my $self = shift;
    if (@_) { $self->{bytes} = shift; }
    return $self->{bytes};
}

sub to_string {
    my $self = shift;

    if ( defined $self->bytes && $self->bytes > 0 ) {
        $self->text( '1 byte' );
        if ( $self->bytes > 1 ) { $self->text( $self->bytes . " bytes" ); }
        return $self->SUPER::to_string;
    }
    return $EMPTY;
}

__PACKAGE__;
__END__
