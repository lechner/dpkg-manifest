#!/usr/bin/perl
#
# Manifest::Field::AnnotatedBinary.pm
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

package Manifest::Field::AnnotatedBinary;

use strict;
use warnings;
use feature qw(switch);
no if $] >= 5.018, warnings => 'experimental::smartmatch';

use Const::Fast;
use MIME::Base64;

use parent 'Manifest::Field::AnnotatedText';

our $VERSION = '0';

const my $EMPTY        => q{};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->set_from_args( 'binary', %args );
    $self->set_from_args( 'encoding', %args );
    $self->set_from_args( 'note', %args );
    return $self;
}

sub binary {
    my $self = shift;
    if (@_) { $self->{binary} = shift; }
    return $self->{binary};
}

sub encoding {
    my $self = shift;
    if (@_) { $self->{encoding} = shift; }
    return $self->{encoding};
}

sub to_string {
    my $self = shift;

    if ( $self->binary ) {
        given ($self->encoding) {
            when ('hex' || 'hexadecimal') {
                $self->text( unpack( 'H*', $self->binary ) );
            }
            when ('bin' || 'binary') {
                $self->text( unpack( 'B*', $self->binary ) );
            }
            default {
                $self->text( encode_base64( $self->binary, $EMPTY ) );
            }
        }
        return $self->SUPER::to_string;
    }
    return $EMPTY;
}

__PACKAGE__;
__END__
