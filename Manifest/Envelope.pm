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

use Manifest::Field::Text;
use Manifest::Field::AnnotatedText;
use Manifest::Field::Date;

our $VERSION = '0';

const my $MANIFEST_FORMAT => '0';
const my $EMPTY   => q{};
const my $DOT     => q{.};
const my $SLASH   => q{/};
const my $NEWLINE => qq{\n};

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->{manifest_format} = Manifest::Field::Text->new(
        label  => q{Manifest-Format},
        text => $MANIFEST_FORMAT
    );

    $self->{title}   = Manifest::Field::Text->new( label => q{Title} );
    $self->{version} = Manifest::Field::Text->new( label => q{Version} );
    $self->{timestamp} = Manifest::Field::Date->new( label => q{Timestamp} );

    $self->{item_tally} = Manifest::Field::AnnotatedText->new(
        label      => q{Tally},
        note => q{Items}
    );

    #    $self->set_value_from_args( 'manifest_format', %args );
    $self->set_value_from_args( 'title',             %args );
    $self->set_value_from_args( 'version',           %args );
    $self->set_value_from_args( 'item_tally',        %args );

    my $now = DateTime->now->set_time_zone('UTC');
    $self->{timestamp}->date_time( $now );

    return $self;
}

sub set_value_from_args {
    my ( $self, $field, %args ) = @_;

    if ( exists $self->{$field} ) {
        $self->{$field}->set_text_from_args( $field, %args );
    }
    return;
}

sub manifest_format {
    my $self = shift;
    if (@_) { $self->{manifest_format}->text(shift); }
    return $self->{manifest_format}->text;
}

sub title {
    my $self = shift;
    if (@_) { $self->{title}->text(shift); }
    return $self->{title}->text;
}

sub version {
    my $self = shift;
    if (@_) { $self->{version}->text(shift); }
    return $self->{version}->text;
}

sub timestamp {
    my $self = shift;
    if (@_) { $self->{timestamp}->date_time(shift); }
    return $self->{timestamp_rfc2822}->date_time;
}

sub item_tally {
    my $self = shift;
    if (@_) { $self->{item_tally}->text(shift); }
    return $self->{item_tally}->text;
}

sub as_list {
    my $self  = shift;
    my @LINES = ();

    push @LINES, $self->{title}->as_list;
    push @LINES, $self->{version}->as_list;
    push @LINES, $self->{timestamp}->as_list;
    push @LINES, $self->{manifest_format}->as_list;
    push @LINES, $self->{item_tally}->as_list;

    return @LINES;
}

__PACKAGE__;
__END__


__PACKAGE__;
__END__
