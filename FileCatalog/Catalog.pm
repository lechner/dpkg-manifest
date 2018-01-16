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
use File::Find::Rule;

use FileCatalog::Item;

const my $EMPTY => q{};
const my $DOT => q{.};
const my $SLASH => q{/};
const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;

    my $self = bless( {}, $class );

    $self->{where} = exists $args{where} ? $args{where} : $EMPTY;

    return $self;
}

sub take_inventory {
    my $self = shift;

    my ( $where ) = @_;

    $self->{Items} = {};

    $self->{Tally} = {};
    my $tally = $self->{Tally};

    my $savecwd = getcwd();
    chdir( $where ) or croak( "Cannot chdir to $where" );
    
    my @SYSTEM_PATHS = File::Find::Rule->not_name( $DOT )->in( $DOT );

    foreach my $system_path( @SYSTEM_PATHS ) {

        my $catalog_path = $DOT . $SLASH . $system_path;
        my $item = FileCatalog::Item->new( path => $catalog_path );

        $self->{Items}{$catalog_path} = $item;

        my $file_type = $item->type;
        if ( not exists $tally->{$file_type} ) {
            $tally->{$file_type} = 0;
        }
        $tally->{$file_type} += 1;
      }

    chdir( $savecwd ) or croak( 'Cannot change back to directory ', $savecwd );
}

sub as_list {
    my $self = shift;

    my ( $print_extra_info ) = @_;

    my @LINES = ();
    foreach my $key ( sort keys %{$self->{Items}} ) {
        my $item = $self->{Items}{$key};
        push( @LINES, $item->as_list );

        my @EXTRA_INFO = $item->extra_info;
        if ($print_extra_info && scalar @EXTRA_INFO) {
            push( @LINES, '--- for information only ---' );
            push( @LINES, @EXTRA_INFO );
          }
      push ( @LINES, $EMPTY );
    }
    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
