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
    $self->{mode}  = FileCatalog::Manifest::Field->new( name => q{File-Mode} );
    $self->{owner} = FileCatalog::Manifest::Field->new( name => q{Owner} );
    $self->{group} = FileCatalog::Manifest::Field->new( name => q{Group} );
    $self->{uid}   = FileCatalog::Manifest::Field->new( name => q{UID} );
    $self->{gid}   = FileCatalog::Manifest::Field->new( name => q{GID} );

    $self->set_value_from_args( 'path', %args );
    $self->set_value_from_args( 'type', %args );
    $self->set_value_from_args( 'mode', %args );
    $self->set_value_from_args( 'owner', %args );
    $self->set_value_from_args( 'group', %args );
    $self->set_value_from_args( 'uid', %args );
    $self->set_value_from_args( 'gid', %args );

    return $self;
}

sub set_value_from_args {
    my $self = shift;
    my ( $field, %args ) = @_;
    if( exists $self->{$field}
        && $self->{$field}->isa('FileCatalog::Manifest::Field') ) {
      $self->{$field}->set_value_from_args( $field, %args );
    }
    return;
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

sub extra_info {
    my $self = shift;
    my @LINES = ();
  
    my $mode = $self->{mode}->to_string;
    my $owner = $self->{owner}->to_string;
    my $group = $self->{group}->to_string;
    my $uid = $self->{uid}->to_string;
    my $gid = $self->{gid}->to_string;

    if( length $mode ) { push( @LINES, $mode ); }
    if( length $owner ) { push( @LINES, $owner ); }
    if( length $group ) { push( @LINES, $group ); }
    if( length $uid ) { push( @LINES, $uid ); }
    if( length $gid ) { push( @LINES, $gid ); }

    return @LINES;
}

sub as_list {
    my $self = shift;
    my @LINES = ();
  
    my $path = $self->{path}->to_string;
    my $type = $self->{type}->to_string;

    if( length $path ) { push( @LINES, $path ); }
    if( length $type ) { push( @LINES, $type ); }

    return @LINES;
}

sub print {
    my $self = shift;
    print join( $NEWLINE, $self->as_list ) . $NEWLINE;
}

__PACKAGE__;
__END__
