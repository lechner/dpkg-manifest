#!/usr/bin/perl
#
# FileCatalog::Manifest::Header.pm
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

package FileCatalog::Manifest::Header;

use strict;
use warnings;

use Const::Fast;

use FileCatalog::Manifest::Field;

our $VERSION = '0';

const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{standard} = FileCatalog::Manifest::Field
      ->new( name => q{Manifest-Format} );

    if ( exists $args{standard} ) {
      $self->{standard}->value( $args{standard} );
    }

    $self->{title} = FileCatalog::Manifest::Field
      ->new( name => q{Title} );
    $self->{version} = FileCatalog::Manifest::Field
      ->new( name => q{Version} );
    $self->{created_rfc2822} = FileCatalog::Manifest::Field
      ->new( name => q{Timestamp}, specifier => q{Mail Format} );
    $self->{created_rfc3339} = FileCatalog::Manifest::Field
      ->new( name => q{Timestamp}, specifier => q{ISO Format} );

    if ( exists $args{title} ) { $self->{title}->value( $args{title} ); }
    if ( exists $args{version} ) { $self->{version}->value( $args{version} ); }
    if ( exists $args{created_rfc2822} ) {
      $self->{created_rfc2822}->value( $args{created_rfc2822} ); }
    if ( exists $args{created_rfc3339} ) {
      $self->{created_rfc3339}->value( $args{created_rfc3339} ); }

    $self->{item_tally} = FileCatalog::Manifest::Field
      ->new( name => q{Tally}, specifier => q{Items} );
    if ( exists $args{item_tally} ) {
      $self->{item_tally}->value( $args{item_tally} ); }

    return $self;
}

sub standard {
    my $self = shift;
    if (@_) { $self->{standard}->value( shift ); }
    return $self->{standard}->value;
}

sub title {
    my $self = shift;
    if (@_) { $self->{title}->value( shift ); }
    return $self->{title}->value;
}

sub version {
    my $self = shift;
    if (@_) { $self->{version}->value( shift ); }
    return $self->{version}->value;
}

sub created_rfc2822 {
    my $self = shift;
    if (@_) { $self->{created_rfc2822}->value( shift ); }
    return $self->{created_rfc2822}->value;
}

sub created_rfc3339 {
    my $self = shift;
    if (@_) { $self->{created_rfc3339}->value( shift ); }
    return $self->{created_rfc3339}->value;
}

sub item_tally {
    my $self = shift;
    if (@_) { $self->{item_tally}->value( shift ); }
    return $self->{item_tally}->value;
}

sub extra_info {
    my $self = shift;
    my @LINES = ();
  
    my $title = $self->{title}->to_string;
    my $version = $self->{version}->to_string;
    my $created_rfc2822 = $self->{created_rfc2822}->to_string;
    my $created_rfc3339 = $self->{created_rfc3339}->to_string;
    my $item_tally = $self->{item_tally}->to_string;

    if( length $title ) { push( @LINES, $title ); }
    if( length $version ) { push( @LINES, $version ); }
    if( length $created_rfc2822 ) { push( @LINES, $created_rfc2822 ); }
    if( length $created_rfc3339 ) { push( @LINES, $created_rfc3339 ); }
    if( length $item_tally ) { push( @LINES, $item_tally ); }

    return @LINES;
}

sub as_list {
    my $self = shift;
    my @LINES = ();

    my $standard = $self->{standard}->to_string;
    if( length $standard ) { push( @LINES, $standard ); }

    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
