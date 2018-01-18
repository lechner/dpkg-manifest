#!/usr/bin/perl
#
# Manifest::Field::Text.pm
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

package Manifest::Field::Text;

use strict;
use warnings;
use Const::Fast;

our $VERSION = '0';

const my $EMPTY        => q{};
const my $SPACE        => q{ };
const my $COLON        => q{:};

sub new {
    my ( $class, %args ) = @_;

    my $self = bless {}, $class;

    $self->set_from_args( 'label', %args );
    $self->set_from_args( 'text', %args );

    return $self;
}

sub set_from_args {
    my ( $self, $which, %args ) = @_;
    $self->{$which} = exists $args{$which} ? $args{$which} : $EMPTY;
    return;
}

sub set_text_from_args {
    my ( $self, $field, %args ) = @_;
    $self->text( exists $args{$field} ? $args{$field} : $EMPTY );
    return;
}

sub label {
    my $self = shift;
    if (@_) { $self->{label} = shift; }
    return $self->{label};
}

sub text {
    my $self = shift;
    if (@_) { $self->{text} = shift; }
    return $self->{text};
}

sub to_string {
    my $self = shift;
    if ( length $self->text ) {
        return $self->label . $COLON . $SPACE . $self->text;
    }
    return $EMPTY;
}

sub as_list {
    my $self = shift;
    my @LINES = ();
    my $line = $self->to_string;
    if ( length $line ) { push @LINES, $line; }
    return @LINES;
}

__PACKAGE__;
__END__
