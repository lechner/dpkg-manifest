#!/usr/bin/perl
#
# FileCatalog::Item.pm
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

package FileCatalog::Item;

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => "experimental::smartmatch";

use Fcntl ':mode';
use File::LibMagic;
use Digest::SHA;
use DateTime::Format::RFC3339;
use Const::Fast;

use FileCatalog::Manifest::RegularFile;
use FileCatalog::Manifest::SymbolicLink;
use FileCatalog::Manifest::Directory;
use FileCatalog::Manifest::CharacterDevice;
use FileCatalog::Manifest::BlockDevice;
use FileCatalog::Manifest::Fifo;
use FileCatalog::Manifest::Socket;

our $VERSION = '0';

const my $EMPTY           => q{};
const my $EQUALS          => q{=};
const my $BASE64_WORDSIZE => 4;

sub pad_base64 {
    my ( $padded ) = @_;
    while ( length($padded) % $BASE64_WORDSIZE ) {
        $padded .= $EQUALS;
    }
    return $padded;
}

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

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
            ) = lstat( $path ) or die( "Cannot stat $path" );;

            my $manifest;

            given ( S_IFMT($mode) ) {

                when (S_IFREG) {
                    $manifest =
                      FileCatalog::Manifest::RegularFile->new( path => $path );

                    $manifest->size($size);
                    $manifest->sha256(
                        pad_base64(
                            Digest::SHA->new(q{SHA-256})->addfile($path)
                              ->b64digest
                        )
                    );
                    $manifest->sha384(
                        pad_base64(
                            Digest::SHA->new(q{SHA-384})->addfile($path)
                              ->b64digest
                        )
                    );
                    $manifest->sha512(
                        pad_base64(
                            Digest::SHA->new(q{SHA-512})->addfile($path)
                              ->b64digest
                        )
                    );

                    my $info = File::LibMagic->new->info_from_filename($path);
                    $manifest->magic( $info->{description} );
                    $manifest->mime_type( $info->{mime_type} );
                    $manifest->encoding( $info->{encoding} );

                }

                when (S_IFDIR) {
                    $manifest =
                      FileCatalog::Manifest::Directory->new( path => $path );
                }

                when (S_IFLNK) {
                    $manifest =
                      FileCatalog::Manifest::SymbolicLink->new( path => $path );
                    $manifest->destination( readlink $path );
                }

                when (S_IFCHR) {
                    $manifest = FileCatalog::Manifest::CharacterDevice->new(
                        path => $path );
                }

                when (S_IFBLK) {
                    $manifest =
                      FileCatalog::Manifest::BlockDevice->new( path => $path );
                }

                when (S_IFIFO) {
                    $manifest =
                      FileCatalog::Manifest::Fifo->new( path => $path );
                }

                when (S_IFSOCK) {
                    $manifest =
                      FileCatalog::Manifest::Socket->new( path => $path );
                }

                default {
                  croak( "Unknown file type $_" );
                }
            }

            $manifest->uid($uid);
            $manifest->gid($gid);
            $manifest->owner( getpwuid $uid );
            $manifest->group( getgrgid $gid );
            my $utc = DateTime->from_epoch( epoch => $mtime )
              ->set_time_zone('UTC');
            my $rfc3339 = DateTime::Format::RFC3339->new;
            $manifest->mtime( $rfc3339->format_datetime( $utc ) );
            $manifest->mode( sprintf "%04o", S_IMODE($mode) );

            $self->{manifest} = $manifest;
        }
    }
    return $self->{path};
}

sub type {
    my $self = shift;
    if ( exists $self->{manifest} ) {
      return $self->{manifest}->type;
    }
    return $EMPTY;
}

sub as_list {
    my $self = shift;
    if ( exists $self->{manifest} ) {
      return $self->{manifest}->as_list;
    }
    return ();
}

sub extra_info {
    my $self = shift;
    if ( exists $self->{manifest} ) {
      return $self->{manifest}->extra_info;
    }
    return ();
}

sub print {
    my $self = shift;
    print $self->to_string;
}

__PACKAGE__;
__END__
