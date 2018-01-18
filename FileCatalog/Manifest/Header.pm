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

const my $MANIFEST_FORMAT => '0';

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->{manifest_format} = FileCatalog::Manifest::Field->new(
        name  => q{Manifest-Format},
        value => $MANIFEST_FORMAT
    );

    $self->{title}   = FileCatalog::Manifest::Field->new( name => q{Title} );
    $self->{version} = FileCatalog::Manifest::Field->new( name => q{Version} );
    $self->{timestamp_rfc2822} = FileCatalog::Manifest::Field->new(
        name      => q{Timestamp},
        specifier => q{RFC2822}
    );
    $self->{timestamp_rfc3339} = FileCatalog::Manifest::Field->new(
        name      => q{Timestamp},
        specifier => q{RFC3339}
    );

    $self->{item_tally} = FileCatalog::Manifest::Field->new(
        name      => q{Tally},
        specifier => q{Items}
    );

    #    $self->set_value_from_args( 'manifest_format', %args );
    $self->set_value_from_args( 'title',             %args );
    $self->set_value_from_args( 'version',           %args );
    $self->set_value_from_args( 'timestamp_rfc2822', %args );
    $self->set_value_from_args( 'timestamp_rfc3339', %args );
    $self->set_value_from_args( 'item_tally',        %args );

    return $self;
}

sub set_value_from_args {
    my ( $self, $field, %args ) = @_;

    if ( exists $self->{$field}
        && $self->{$field}->isa('FileCatalog::Manifest::Field') )
    {
        $self->{$field}->set_value_from_args( $field, %args );
    }
    return;
}

sub manifest_format {
    my $self = shift;
    if (@_) { $self->{manifest_format}->value(shift); }
    return $self->{manifest_format}->value;
}

sub title {
    my $self = shift;
    if (@_) { $self->{title}->value(shift); }
    return $self->{title}->value;
}

sub version {
    my $self = shift;
    if (@_) { $self->{version}->value(shift); }
    return $self->{version}->value;
}

sub timestamp_rfc2822 {
    my $self = shift;
    if (@_) { $self->{timestamp_rfc2822}->value(shift); }
    return $self->{timestamp_rfc2822}->value;
}

sub timestamp_rfc3339 {
    my $self = shift;
    if (@_) { $self->{timestamp_rfc3339}->value(shift); }
    return $self->{timestamp_rfc3339}->value;
}

sub item_tally {
    my $self = shift;
    if (@_) { $self->{item_tally}->value(shift); }
    return $self->{item_tally}->value;
}

sub extra_info {
    my $self  = shift;
    my @LINES = ();

    return @LINES;
}

sub as_list {
    my $self  = shift;
    my @LINES = ();

    my $title             = $self->{title}->to_string;
    my $version           = $self->{version}->to_string;
    my $timestamp_rfc2822 = $self->{timestamp_rfc2822}->to_string;
    my $timestamp_rfc3339 = $self->{timestamp_rfc3339}->to_string;
    my $manifest_format   = $self->{manifest_format}->to_string;
    my $item_tally        = $self->{item_tally}->to_string;

    if ( length $title )             { push @LINES, $title; }
    if ( length $version )           { push @LINES, $version; }
    if ( length $timestamp_rfc2822 ) { push @LINES, $timestamp_rfc2822; }
    if ( length $timestamp_rfc3339 ) { push @LINES, $timestamp_rfc3339; }
    if ( length $manifest_format )   { push @LINES, $manifest_format; }
    if ( length $item_tally )        { push @LINES, $item_tally; }

    return @LINES;
}

__PACKAGE__;
__END__
