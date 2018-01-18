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
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;

use Manifest::Field::Text;
use Manifest::Field::AnnotatedText;

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
    $self->{timestamp_rfc2822} = Manifest::Field::AnnotatedText->new(
        label      => q{Timestamp},
        note => q{RFC2822}
    );
    $self->{timestamp_rfc3339} = Manifest::Field::AnnotatedText->new(
        label      => q{Timestamp},
        note => q{RFC3339}
    );

    $self->{item_tally} = Manifest::Field::AnnotatedText->new(
        label      => q{Tally},
        note => q{Items}
    );

    #    $self->set_value_from_args( 'manifest_format', %args );
    $self->set_value_from_args( 'title',             %args );
    $self->set_value_from_args( 'version',           %args );
#    $self->set_value_from_args( 'timestamp_rfc2822', %args );
#    $self->set_value_from_args( 'timestamp_rfc3339', %args );
    $self->set_value_from_args( 'item_tally',        %args );

    my $now     = DateTime->now->set_time_zone('UTC');
    my $rfc2822 = DateTime::Format::Mail->new;
    my $rfc3339 = DateTime::Format::RFC3339->new;
    $self->timestamp_rfc2822( $rfc2822->format_datetime($now) );
    #    $header->timestamp_rfc3339( $rfc3339->format_datetime( $now ) );

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

sub timestamp_rfc2822 {
    my $self = shift;
    if (@_) { $self->{timestamp_rfc2822}->text(shift); }
    return $self->{timestamp_rfc2822}->text;
}

sub timestamp_rfc3339 {
    my $self = shift;
    if (@_) { $self->{timestamp_rfc3339}->text(shift); }
    return $self->{timestamp_rfc3339}->text;
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
    push @LINES, $self->{timestamp_rfc2822}->as_list;
    push @LINES, $self->{timestamp_rfc3339}->as_list;
    push @LINES, $self->{manifest_format}->as_list;
    push @LINES, $self->{item_tally}->as_list;

    return @LINES;
}

__PACKAGE__;
__END__


__PACKAGE__;
__END__
