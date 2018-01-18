#!/usr/bin/perl
#
# Manifest::Field::AnnotatedText.pm
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

package Manifest::Field::AnnotatedText;

use strict;
use warnings;
use Const::Fast;

use parent 'Manifest::Field::Text';

our $VERSION = '0';

const my $EMPTY        => q{};
const my $SPACE        => q{ };
const my $COLON        => q{:};
const my $LEFT_SQUARE  => q{[};
const my $RIGHT_SQUARE => q{]};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->set_from_args( 'note', %args );
    return $self;
}

sub note {
    my $self = shift;
    if (@_) { $self->{note} = shift; }
    return $self->{note};
}

sub to_string {
    my $self = shift;
  
    if ( length $self->text ) {
        my $annotation = $self->note
            ? $LEFT_SQUARE . $self->note . $RIGHT_SQUARE . $SPACE
            : $EMPTY;

        return $self->label . $COLON . $SPACE . $annotation . $self->text;
    }
    return $EMPTY;
}

__PACKAGE__;
__END__
