#!/usr/bin/perl
#
# Manifest::ScanFiles.pm
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

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => "experimental::smartmatch";

use Carp;
use File::Find::Rule;
use Fcntl ':mode';
use File::LibMagic;
use Digest::SHA;

# module version
our $VERSION = 0;

# file types
my $REGULAR          = q{Regular};
my $DIRECTORY        = q{Directory};
my $LINK             = q{Link};
my $CHARACTER_DEVICE = q{Character-Device};
my $BLOCK_DEVICE     = q{Block-Device};
my $FIFO             = q{Fifo};
my $SOCKET           = q{Socket};

my @FILE_TYPES = (
    $REGULAR, $DIRECTORY, $LINK, $CHARACTER_DEVICE, $BLOCK_DEVICE, $FIFO,
    $SOCKET,
);

# overall output fields
my $MANIFEST_VERSION  = q{Manifest-Version};
my $TITLE             = q(Title);
my $RUNNING_DIGEST    = q{Running-Digest};
my $DIGEST_COMPONENTS = q{Digest-Components};
my $ITEM              = q{Item};
my $TALLY             = q{Tally};

# per-file output fields
my $PATH              = q{Path};
my $FILE_TYPE         = q{File-Type};
my $CONTENT           = q{Content};
my $DESTINATION       = q{Destination};
my $OWNER             = q{Owner};
my $GROUP             = q{Group};
my $UID               = q{Uid};
my $GID               = q{Gid};
my $PERMISSIONS       = q{Permissions};
my $MODIFICATION_TIME = q{Modification-Time};

# extra information
my $MAGIC        = q{Magic};
my $MIME_TYPE    = q{Mime-Type};
my $ENCODING     = q{Encoding};
my $CONTENT_SIZE = q{Content-Size};

my @FIELD_NAMES = (
    $PATH,        $FILE_TYPE, $CONTENT, $DESTINATION,
    $OWNER,       $GROUP,     $UID,     $GID,
    $PERMISSIONS, $MODIFICATION_TIME,
);

# SHA digests
my @SHA_ALGORITHMS = qw{SHA-256 SHA-384 SHA-512};

my $MODE_TO_TYPE = {
    S_IFREG()  => $REGULAR,
    S_IFDIR()  => $DIRECTORY,
    S_IFLNK()  => $LINK,
    S_IFCHR()  => $CHARACTER_DEVICE,
    S_IFBLK()  => $BLOCK_DEVICE,
    S_IFIFO()  => $FIFO,
    S_IFSOCK() => $SOCKET,
};

my $BASE64_WORDSIZE = 4;

sub pad_base64 {
    my ($padded) = @_;
    while ( length($padded) % $BASE64_WORDSIZE ) {
        $padded .= q{=};
    }
    return $padded;
}

sub scan_files {

    my ( $where, $include ) = @_;

    my $catalog = {};
    $catalog->{$ITEM}           = {};
    $catalog->{$RUNNING_DIGEST} = {};
    $catalog->{$TALLY}          = {};

    my $tally = $catalog->{$TALLY};

    my $magic = File::LibMagic->new();

    my $runningShaState = {};
    foreach my $algorithm (@SHA_ALGORITHMS) {
        $runningShaState->{$algorithm} = Digest::SHA->new($algorithm);
    }

    # maybe use absolute file names?

    my @SYSTEM_PATHS =
      sort File::Find::Rule->not( File::Find::Rule->name(q{.}) )->in($where);

    foreach my $systemPath (@SYSTEM_PATHS) {

        my $skip = $where ne q{.} ? length $where : 0;
        my $catalogPath = q{./} . substr( $systemPath, $skip );

        # add path to digests
        foreach my $algorithm (@SHA_ALGORITHMS) {
            $runningShaState->{$algorithm}->add($catalogPath);
        }

        my $item = {};
        $catalog->{$ITEM}{$catalogPath} = $item;

        my (
            $dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
            $size, $atime, $mtime, $ctime, $blksize, $blocks
        ) = lstat($systemPath);

        $item->{$CONTENT_SIZE}      = $size;
        $item->{$MODIFICATION_TIME} = $mtime;
        $item->{$UID}               = $uid;
        $item->{$GID}               = $gid;
        $item->{$OWNER}             = getpwuid $uid;
        $item->{$GROUP}             = getgrgid $gid;
        $item->{$PERMISSIONS}       = sprintf "%04o", S_IMODE($mode);

        $item->{$FILE_TYPE} = $MODE_TO_TYPE->{ S_IFMT($mode) }
          or die "Unknown file type";

        if ( not defined $tally->{ $item->{$FILE_TYPE} } ) {
            $tally->{ $item->{$FILE_TYPE} } = 0;
        }
        $tally->{ $item->{$FILE_TYPE} } += 1;

        given ( $item->{$FILE_TYPE} ) {

            when ($REGULAR) {
                $tally->{$CONTENT_SIZE} += $size;

                my $info = $magic->info_from_filename($systemPath);
                $item->{$MAGIC}     = $info->{description};
                $item->{$MIME_TYPE} = $info->{mime_type};
                $item->{$ENCODING}  = $info->{encoding};

                # calculate content digests
                $item->{$CONTENT} = {};
                foreach my $algorithm (@SHA_ALGORITHMS) {
                    $item->{$CONTENT}{$algorithm} =
                      pad_base64(
                        Digest::SHA->new($algorithm)->addfile($systemPath)
                          ->b64digest );
                }

                # also add content to overall digests
                foreach my $algorithm (@SHA_ALGORITHMS) {
                    $runningShaState->{$algorithm}->addfile($systemPath);
                }

                # add other elements represented in manifest
            }

            when ($DIRECTORY) {
            }

            when ($LINK) {

                #                $tally->{$CONTENT_SIZE} += $size;
                my $destination = readlink $systemPath;
                $item->{$DESTINATION} = $destination;
                foreach my $algorithm (@SHA_ALGORITHMS) {
                    $runningShaState->{$algorithm}->add($destination);
                }
            }

            when ($CHARACTER_DEVICE) {
            }

            when ($BLOCK_DEVICE) {
            }

            when ($FIFO) {
            }

            when ($SOCKET) {
            }

            default {
                croak 'Unknown file type';
            }
        }
    }

    foreach my $algorithm (@SHA_ALGORITHMS) {
        $catalog->{$RUNNING_DIGEST}{$algorithm} =
          pad_base64( $runningShaState->{$algorithm}->b64digest );
    }

    return $catalog;
}
