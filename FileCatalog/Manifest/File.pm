#!/usr/bin/perl
#
# FileCatalog::Manifest::File.pm
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

package FileCatalog::Manifest::File;

use strict;
use warnings;

use Const::Fast;

use FileCatalog::Manifest::Field;

our $VERSION = '0';

const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{path} = FileCatalog::Manifest::Field->new( name => q{Path} );
    $self->{type} = FileCatalog::Manifest::Field->new( name => q{File-Type} );

    if ( exists $args{path} ) { $self->{path}->value( $args{path} ); }
    if ( exists $args{type} ) { $self->{type}->value( $args{type} ); }

    $self->{uid}   = FileCatalog::Manifest::Field->new( name => q{UID} );
    $self->{gid}   = FileCatalog::Manifest::Field->new( name => q{GID} );
    $self->{owner} = FileCatalog::Manifest::Field->new( name => q{Owner} );
    $self->{group} = FileCatalog::Manifest::Field->new( name => q{Group} );
    $self->{mode}  = FileCatalog::Manifest::Field->new( name => q{File-Mode} );
    $self->{mtime} =
      FileCatalog::Manifest::Field->new( name => q{Modification-Time} );

    if ( exists $args{uid} )   { $self->{uid}->value( $args{uid} ); }
    if ( exists $args{gid} )   { $self->{gid}->value( $args{gid} ); }
    if ( exists $args{owner} ) { $self->{owner}->value( $args{owner} ); }
    if ( exists $args{group} ) { $self->{group}->value( $args{group} ); }
    if ( exists $args{mode} )  { $self->{mode}->value( $args{mode} ); }
    if ( exists $args{mtime} ) { $self->{mtime}->value( $args{mtime} ); }

    return $self;
}

sub path {
    my $self = shift;
    if (@_) { $self->{path}->value( shift ); }
    return $self->{path}->value;
}

sub type {
    my $self = shift;
    if (@_) { $self->{type}->value( shift ); }
    return $self->{type}->value;
}

sub uid {
    my $self = shift;
    if (@_) { $self->{uid}->value( shift ); }
    return $self->{uid}->value;
}

sub gid {
    my $self = shift;
    if (@_) { $self->{gid}->value( shift ); }
    return $self->{gid}->value;
}

sub owner {
    my $self = shift;
    if (@_) { $self->{owner}->value( shift ); }
    return $self->{owner}->value;
}

sub group {
    my $self = shift;
    if (@_) { $self->{group}->value( shift ); }
    return $self->{group}->value;
}

sub mode {
    my $self = shift;
    if (@_) { $self->{mode}->value( shift ); }
    return $self->{mode}->value;
}

sub mtime {
    my $self = shift;
    if (@_) { $self->{mtime}->value(shift); }
    return $self->{mtime}->value;
}

sub extra_info {
    my $self = shift;
    my @LINES = ();
  
    my $uid = $self->{uid}->to_string;
    my $gid = $self->{gid}->to_string;
    if( length $uid ) { push( @LINES, $uid ); }
    if( length $gid ) { push( @LINES, $gid ); }

    my $owner = $self->{owner}->to_string;
    my $group = $self->{group}->to_string;
    if( length $owner ) { push( @LINES, $owner ); }
    if( length $group ) { push( @LINES, $group ); }

    my $mode = $self->{mode}->to_string;
    my $mtime = $self->{mtime}->to_string;
    if( length $mode ) { push( @LINES, $mode ); }
    if( length $mtime ) { push( @LINES, $mtime ); }

    return @LINES;
}

sub as_list {
    my $self = shift;
    my @LINES = ();
  
    my $path = $self->{path}->to_string;
    if( length $path ) { push( @LINES, $path ); }

    my $type = $self->{type}->to_string;
    if( length $type ) { push( @LINES, $type ); }

    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
