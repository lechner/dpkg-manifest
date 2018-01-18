#!/usr/bin/perl
#
# Manifest::Field::Date.pm
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

package Manifest::Field::Date;

use strict;
use warnings;
use feature qw(switch);
no if $] >= 5.018, warnings => 'experimental::smartmatch';


use Const::Fast;
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;

use parent 'Manifest::Field::AnnotatedText';

our $VERSION = '0';

const my $EMPTY        => q{};
const my $ISO          => q{iso};

sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new(%args);

    $self->set_from_args( 'date_time', %args );
    $self->set_from_args( 'timestamp_format', %args );
    return $self;
}

sub timestamp_format {
    my $self = shift;
    if (@_) { $self->{timestamp_format} = shift; }
    return $self->{timestamp_format};
}

sub date_time {
    my $self = shift;
    if (@_) { $self->{date_time} = shift; }
    return $self->{date_time};
}

sub to_string {
    my $self = shift;

    if ( $self->date_time ) {
        given ($self->{timestamp_format}) {
            when ('iso') {
                my $rfc3339 = DateTime::Format::RFC3339->new;
                $self->text( $rfc3339->format_datetime( $self->date_time ) );
                $self->note( 'RFC3339' );
            }
            default {
              my $rfc2822 = DateTime::Format::Mail->new;
                $self->text( $rfc2822->format_datetime( $self->date_time ) );
                $self->note( 'RFC2822' );
            }
        }
        return $self->SUPER::to_string;
    }
    return $EMPTY;
}

__PACKAGE__;
__END__
