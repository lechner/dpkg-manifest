#!/usr/bin/perl
#
# Manifest::Item::File.pm
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

package Manifest::Item::File;

use strict;
use warnings;

use Const::Fast;

use Manifest::Field::AnnotatedText;

our $VERSION = '0';

const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->{path}  = Manifest::Field::Text->new( label => q{Path} );
    $self->{type}  = Manifest::Field::Text->new( label => q{File-Type} );
    $self->{mode}  = Manifest::Field::Text->new( label => q{File-Mode} );
    $self->{owner} = Manifest::Field::Text->new( label => q{Owner} );
    $self->{group} = Manifest::Field::Text->new( label => q{Group} );
    $self->{uid}   = Manifest::Field::Text->new( label => q{UID} );
    $self->{gid}   = Manifest::Field::Text->new( label => q{GID} );

    $self->set_value_from_args( 'path',  %args );
    $self->set_value_from_args( 'type',  %args );
    $self->set_value_from_args( 'mode',  %args );
    $self->set_value_from_args( 'owner', %args );
    $self->set_value_from_args( 'group', %args );
    $self->set_value_from_args( 'uid',   %args );
    $self->set_value_from_args( 'gid',   %args );

    return $self;
}

sub set_value_from_args {
    my ( $self, $field, %args ) = @_;

    if ( exists $self->{$field} ) {
        $self->{$field}->set_text_from_args( $field, %args );
    }
    return;
}

sub path {
    my $self = shift;
    if (@_) { $self->{path}->text(shift); }
    return $self->{path}->text;
}

sub type {
    my $self = shift;
    if (@_) { $self->{type}->text(shift); }
    return $self->{type}->text;
}

sub uid {
    my $self = shift;
    if (@_) { $self->{uid}->text(shift); }
    return $self->{uid}->text;
}

sub gid {
    my $self = shift;
    if (@_) { $self->{gid}->text(shift); }
    return $self->{gid}->text;
}

sub owner {
    my $self = shift;
    if (@_) { $self->{owner}->text(shift); }
    return $self->{owner}->text;
}

sub group {
    my $self = shift;
    if (@_) { $self->{group}->text(shift); }
    return $self->{group}->text;
}

sub mode {
    my $self = shift;
    if (@_) { $self->{mode}->text(shift); }
    return $self->{mode}->text;
}

sub extra_info {
    my $self  = shift;
    my @LINES = ();

    push @LINES, $self->{mode}->as_list;
    push @LINES, $self->{owner}->as_list;
    push @LINES, $self->{group}->as_list;
    push @LINES, $self->{uid}->as_list;
    push @LINES, $self->{gid}->as_list;

    return @LINES;
}

sub as_list {
    my $self  = shift;
    my @LINES = ();

    push @LINES, $self->{path}->as_list;
    push @LINES, $self->{type}->as_list;

    return @LINES;
}

__PACKAGE__;
__END__
