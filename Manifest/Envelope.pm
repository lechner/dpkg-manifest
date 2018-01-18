#!/usr/bin/perl
#
# Manifest::Envelope.pm
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

package Manifest::Envelope;

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => 'experimental::smartmatch';

use Carp;
use Const::Fast;
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;

use Manifest::Header;

our $VERSION = '0';

const my $EMPTY   => q{};
const my $DOT     => q{.};
const my $SLASH   => q{/};
const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->{Header} = Manifest::Header->new(%args);
    my $header = $self->{Header};

    my $now     = DateTime->now->set_time_zone('UTC');
    my $rfc2822 = DateTime::Format::Mail->new;
    my $rfc3339 = DateTime::Format::RFC3339->new;
    $header->timestamp_rfc2822( $rfc2822->format_datetime($now) );
    #    $header->timestamp_rfc3339( $rfc3339->format_datetime( $now ) );

    return $self;
}

sub as_list {
    my $self = shift;

    my $header = $self->{Header};

    my @LINES = ();

    push @LINES, $header->as_list;

    return @LINES;
}

__PACKAGE__;
__END__
