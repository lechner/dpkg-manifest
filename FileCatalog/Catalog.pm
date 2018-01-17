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
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;

use FileCatalog::Manifest::Header;
use FileCatalog::Item;

const my $EMPTY => q{};
const my $DOT => q{.};
const my $SLASH => q{/};
const my $NEWLINE => qq{\n};

const my $standard => '0';

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{where} = exists $args{where} ? $args{where} : $EMPTY;

    $self->{Items} = {};
    $self->{Tally} = {};

    $self->{Header} = FileCatalog::Manifest::Header->new;

    return $self;
}

sub take_inventory {
    my $self = shift;

    my ( $where ) = @_;

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

    my $title = "Upstream Release";
    my $version = "3.2.3";

    my $header = $self->{Header};
    $header->standard( $standard );
    $header->title( $title );
    $header->version( $version );

    my $now = DateTime->now->set_time_zone( 'UTC' );
    my $rfc2822 = DateTime::Format::Mail->new;
    my $rfc3339 = DateTime::Format::RFC3339->new;
    $header->created_rfc2822( $rfc2822->format_datetime( $now ) );
    $header->created_rfc3339( $rfc3339->format_datetime( $now ) );

    my $item_tally = 0;
    foreach my $file_type ( keys %{$tally} ) {
      $item_tally += $tally->{$file_type};
    }
    $header->item_tally( $item_tally );
}

sub as_list {
    my $self = shift;

    my ( $print_extra_info ) = @_;

    my $header = $self->{Header};
    
    my @LINES = ();
    
    push( @LINES, $header->{title}->to_string );
    push( @LINES, $header->{version}->to_string );
    push( @LINES, $header->{created_rfc2822}->to_string );
    push( @LINES, $header->{created_rfc3339}->to_string );
    push( @LINES, $header->{item_tally}->to_string );
    push( @LINES, $EMPTY );
    push( @LINES, '*  *  *  CATALOG STARTS BELOW  *  *  *' );
    push( @LINES, $EMPTY );

    foreach my $key ( sort keys %{$self->{Items}} ) {
        my $item = $self->{Items}{$key};
        push( @LINES, $item->formatted( $print_extra_info ) );
        push( @LINES, $EMPTY );
    }
    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
