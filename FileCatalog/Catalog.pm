#!/usr/bin/perl
#
# FileCatalog::Catalog.pm
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

package FileCatalog::Catalog;

our $VERSION = '0';

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => "experimental::smartmatch";

use Carp;
use Const::Fast;
use Cwd;
use SHARYANTO::String::Util qw(trim);
use List::Util qw(min max);
use File::Find::Rule;

use FileCatalog::Envelope;
use FileCatalog::Item;

const my $EMPTY   => q{};
const my $DOT     => q{.};
const my $SLASH   => q{/};
const my $SPACE   => q{ };
const my $DASH    => q{-};
const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{where} = exists $args{where} ? $args{where} : $EMPTY;

    $self->{Items} = {};
    $self->{Tally} = {};

    return $self;
}

sub take_inventory {
    my $self = shift;

    my ($where) = @_;

    my $tally = $self->{Tally};

    my $savecwd = getcwd();
    chdir($where) or croak("Cannot chdir to $where");

    my @SYSTEM_PATHS = File::Find::Rule->not_name($DOT)->in($DOT);

    foreach my $system_path (@SYSTEM_PATHS) {

        my $catalog_path = $DOT . $SLASH . $system_path;
        my $item = FileCatalog::Item->new( path => $catalog_path );

        $self->{Items}{$catalog_path} = $item;

        my $file_type = $item->type;
        if ( not exists $tally->{$file_type} ) {
            $tally->{$file_type} = 0;
        }
        $tally->{$file_type} += 1;
    }

    chdir($savecwd) or croak( 'Cannot change back to directory ', $savecwd );

    my $title   = "Upstream Release";
    my $version = "3.2.3";

    my $item_tally = 0;
    foreach my $file_type ( keys %{$tally} ) {
        $item_tally += $tally->{$file_type};
    }

    $self->{Envelope} = FileCatalog::Envelope->new(
        title      => $title,
        version    => $version,
        item_tally => $item_tally
    );
}

sub label {
    my $self = shift;
    my ( $separator, $pad, $text, $width ) = @_;

    my $trimmed = trim $text;

    my $sides     = $width - length $trimmed;
    my $rightside = max( 0, int( 0.5 + $sides / 2 ) );
    my $leftside  = max( 0, $sides - $rightside );

    my $leftline  = $separator x max( 0, $leftside - $pad );
    my $rightline = $separator x max( 0, $rightside - $pad );

    my $leftpad  = $SPACE x max( 0, min( $pad, $leftside - $pad ) );
    my $rightpad = $SPACE x max( 0, min( $pad, $rightside - $pad ) );

    return $leftline . $leftpad . $trimmed . $rightpad . $rightline;
}

sub as_list {
    my $self = shift;
    my ($print_extra_info) = @_;

    my @LINES = ();

    my @ENVELOPE_LINES = $self->{Envelope}->as_list;

    if ( scalar @ENVELOPE_LINES ) {
        push( @LINES, $self->label( $DASH, 1, 'Shipping Manifest',   72 ) );
        push( @LINES, @ENVELOPE_LINES );
        push( @LINES, $self->label( $DASH, 1, 'Validated From Here', 72 ) );
    }

    my @CATALOG_PATHS = sort keys %{ $self->{Items} };
    my $countdown     = scalar @CATALOG_PATHS;

    foreach my $path (@CATALOG_PATHS) {
        my $item = $self->{Items}{$path};
        push( @LINES, $item->formatted($print_extra_info) );
        $countdown -= 1;
        if ( $countdown > 1 ) {
            push( @LINES, $EMPTY );
        }
    }
    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
