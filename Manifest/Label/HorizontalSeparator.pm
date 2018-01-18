#!/usr/bin/perl
#
# Manifest::Label::HorizontalSeparator.pm
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

package Manifest::Label::HorizontalSeparator;

use strict;
use warnings;
use Const::Fast;
use SHARYANTO::String::Util qw(trim);
use List::Util qw(min max);

our $VERSION = '0';

const my $EMPTY        => q{};
const my $SPACE        => q{ };
const my $ONE_HALF     => 0.5;

sub new {
    my ( $class, %args ) = @_;

    my $self = bless {}, $class;

    $self->set_from_args( 'separator', %args );
    $self->set_from_args( 'pad_width', %args );
    $self->set_from_args( 'line_width', %args );

    return $self;
}

sub set_from_args {
    my ( $self, $which, %args ) = @_;
    $self->{$which} = exists $args{$which} ? $args{$which} : $EMPTY;
    return;
}

sub label {
    my ( $self, $text ) = @_;

    my $trimmed = trim $text;

    my $sides     = $self->line_width - length $trimmed;
    my $rightside = max( 0, int( $ONE_HALF + $sides / 2 ) );
    my $leftside  = max( 0, $sides - $rightside );

    my $pad = $self->pad_width;
    my $separator = $self->separator;

    my $leftline  = $separator x max( 0, $leftside - $pad );
    my $rightline = $separator x max( 0, $rightside - $pad );

    my $leftpad  = $SPACE x max( 0, min( $pad, $leftside - $pad ) );
    my $rightpad = $SPACE x max( 0, min( $pad, $rightside - $pad ) );

    return $leftline . $leftpad . $trimmed . $rightpad . $rightline;
}

sub separator {
    my $self = shift;
    if (@_) { $self->{separator} = shift; }
    return $self->{separator};
}

sub pad_width {
    my $self = shift;
    if (@_) { $self->{pad_width} = shift; }
    return $self->{pad_width};
}

sub line_width {
    my $self = shift;
    if (@_) { $self->{line_width} = shift; }
    return $self->{line_width};
}

__PACKAGE__;
__END__
