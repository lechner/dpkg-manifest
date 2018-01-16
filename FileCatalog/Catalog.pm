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
use File::Find::Rule;

use FileCatalog::Item;

const my $EMPTY => q{};
const my $CWD => q{.};
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

    my @SYSTEM_PATHS =
      sort File::Find::Rule->not( File::Find::Rule->name(q{.}) )->in( $where );

    foreach my $system_path (@SYSTEM_PATHS) {

        my $item = FileCatalog::Item->new( path => $system_path );

        # maybe use absolute file names?
        my $skip = $where ne $CWD ? length $where : 0;
        my $catalog_path = $CWD . $SLASH . substr( $system_path, $skip );

        $self->{Items}{$catalog_path} = $item;

        my $file_type = $item->type;
        if ( not defined $tally->{$file_type} ) {
            $tally->{$file_type} = 0;
        }
        $tally->{$file_type} += 1;

    }
}

sub to_string {
    my $self = shift;

    my ( $print_extra_info ) = @_;

    my @LINES = ();
    foreach my $key ( sort keys %{$self->{Items}} ) {
      my $item = $self->{Items}{$key};
      push( @LINES, $item->to_string );
        
        if ($print_extra_info && $item->extra_info) {
            push( @LINES, '--- for information only ---' . $NEWLINE );
            push( @LINES, $item->extra_info );
          }
      push ( @LINES, $NEWLINE );
    }
    return join( $EMPTY,  @LINES );
}

sub print {
    my $self = shift;
    print $self->to_string;
}

__PACKAGE__;
__END__
