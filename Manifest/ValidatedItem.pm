#!/usr/bin/perl
#
# Manifest::ValidatedItem.pm
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

package Manifest::ValidatedItem;

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => 'experimental::smartmatch';

use Digest::SHA;
use Number::Format;
use Fcntl ':mode';
use File::LibMagic;
use Const::Fast;

use Manifest::Item::RegularFile;
use Manifest::Item::SymbolicLink;
use Manifest::Item::Directory;
use Manifest::Item::CharacterDevice;
use Manifest::Item::BlockDevice;
use Manifest::Item::Fifo;
use Manifest::Item::Socket;

our $VERSION = '0';

const my $EMPTY           => q{};
const my $EQUALS          => q{=};
const my $BASE64_WORDSIZE => 4;

sub pad_base64 {
    my ($padded) = @_;
    while ( length($padded) % $BASE64_WORDSIZE ) {
        $padded .= $EQUALS;
    }
    return $padded;
}

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->path( exists $args{path} ? $args{path} : $EMPTY );

    return $self;
}

sub path {
    my $self = shift;
    if (@_) {
        $self->{path} = shift;
        my $path = $self->{path};

        if ( $path ne $EMPTY ) {
            my (
                $dev,   $ino,     $mode, $nlink, $uid,
                $gid,   $rdev,    $size, $atime, $mtime,
                $ctime, $blksize, $blocks
              )
              = lstat $path
              or croak("Cannot stat $path");

            my $entry;

            given ( S_IFMT($mode) ) {

                when (S_IFREG) {
                    $entry = Manifest::Item::RegularFile->new( path => $path );
                    my $utc = DateTime->from_epoch( epoch => $mtime )
                      ->set_time_zone('UTC');
                    $entry->mtime( $utc );

                    $entry->exact_size($size);
                    my $nf     = Number::Format->new;
                    my $common = $nf->format_bytes(
                        $size,
                        mode      => 'iec',
                        precision => 1
                    );
                    $entry->common_size($common);

                    $entry->sha256(
                        pad_base64(
                            Digest::SHA->new(q{SHA-256})->addfile($path)
                              ->b64digest
                        )
                    );
                    $entry->sha384(
                        pad_base64(
                            Digest::SHA->new(q{SHA-384})->addfile($path)
                              ->b64digest
                        )
                    );
                    $entry->sha512(
                        pad_base64(
                            Digest::SHA->new(q{SHA-512})->addfile($path)
                              ->b64digest
                        )
                    );

                    my $info = File::LibMagic->new->info_from_filename($path);
                    $entry->magic( $info->{description} );
                    $entry->mime_type( $info->{mime_type} );
                    $entry->encoding( $info->{encoding} );

                }

                when (S_IFDIR) {
                    $entry =
                      Manifest::Item::Directory->new( path => $path );
                }

                when (S_IFLNK) {
                    $entry =
                      Manifest::Item::SymbolicLink->new( path => $path );
                    $entry->destination( readlink $path );
                }

                when (S_IFCHR) {
                    $entry = Manifest::Item::CharacterDevice->new(
                        path => $path );
                }

                when (S_IFBLK) {
                    $entry =
                      Manifest::Item::BlockDevice->new( path => $path );
                }

                when (S_IFIFO) {
                    $entry = Manifest::Item::Fifo->new( path => $path );
                }

                when (S_IFSOCK) {
                    $entry =
                      Manifest::Item::Socket->new( path => $path );
                }

                default {
                    croak("Unknown file type $_");
                }
            }

            $entry->mode( sprintf '%04o', S_IMODE($mode) );
            $entry->owner( getpwuid $uid );
            $entry->group( getgrgid $gid );
            $entry->uid($uid);
            $entry->gid($gid);

            $self->{entry} = $entry;
        }
    }
    return $self->{path};
}

sub type {
    my $self = shift;
    if ( exists $self->{entry} ) {
        return $self->{entry}->type;
    }
    return $EMPTY;
}

sub as_list {
    my $self = shift;
    if ( exists $self->{entry} ) {
        return $self->{entry}->as_list;
    }
    return ();
}

sub extra_info {
    my $self = shift;
    if ( exists $self->{entry} ) {
        return $self->{entry}->extra_info;
    }
    return ();
}

sub formatted {
    my ( $self, $print_extra_info ) = @_;

    my @LINES = ();

    push @LINES, $self->as_list;

    my @EXTRA_INFO = $self->extra_info;
    if ( $print_extra_info && scalar @EXTRA_INFO ) {
        push @LINES, '--- unverified data follows ---';
        push @LINES, @EXTRA_INFO;
    }

    return @LINES;
}

__PACKAGE__;
__END__
