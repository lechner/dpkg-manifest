#!/usr/bin/perl
#
# FileCatalog::Fields.pm
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


package FileCatalog::Fields;

use strict;
use warnings;
use Exporter qw( import );
use Const::Fast;

our $VERSION = '0';

our @EXPORT = qw(
  $MANIFEST_VERSION
  $TITLE
  $RUNNING_DIGEST
  $DIGEST_COMPONENTS
  $ITEM
  $TALLY

  $REGULAR
  $DIRECTORY
  $LINK
  $CHARACTER_DEVICE
  $BLOCK_DEVICE
  $FIFO
  $SOCKET

  @FILE_TYPES

  $PATH
  $FILE_TYPE
  $CONTENT
  $DESTINATION
  $OWNER
  $GROUP
  $UID
  $GID
  $PERMISSIONS
  $MODIFICATION_TIME

  @FIELD_NAMES

  $MAGIC
  $MIME_TYPE
  $ENCODING
  $CONTENT_SIZE

  @SHA_ALGORITHMS

);

our @EXPORT_OK = qw();

# header fields
const our $MANIFEST_VERSION  => q{Manifest-Version};
const our $TITLE             => q(Title);
const our $RUNNING_DIGEST    => q{Running-Digest};
const our $DIGEST_COMPONENTS => q{Digest-Components};
const our $ITEM              => q{Item};
const our $TALLY             => q{Tally};

# file types
const our $REGULAR          => q{Regular};
const our $DIRECTORY        => q{Directory};
const our $LINK             => q{Link};
const our $CHARACTER_DEVICE => q{Character-Device};
const our $BLOCK_DEVICE     => q{Block-Device};
const our $FIFO             => q{Fifo};
const our $SOCKET           => q{Socket};

const our @FILE_TYPES => (
    $REGULAR, $DIRECTORY, $LINK, $CHARACTER_DEVICE, $BLOCK_DEVICE, $FIFO,
    $SOCKET,
);

# per-file fields
const our $PATH              => q{Path};
const our $FILE_TYPE         => q{File-Type};
const our $CONTENT           => q{Content};
const our $DESTINATION       => q{Destination};
const our $OWNER             => q{Owner};
const our $GROUP             => q{Group};
const our $UID               => q{Uid};
const our $GID               => q{Gid};
const our $PERMISSIONS       => q{Permissions};
const our $MODIFICATION_TIME => q{Modification-Time};

const our @FIELD_NAMES => (
    $PATH,        $FILE_TYPE, $CONTENT, $DESTINATION,
    $OWNER,       $GROUP,     $UID,     $GID,
    $PERMISSIONS, $MODIFICATION_TIME,
);

# extra per-file information
const our $MAGIC        => q{Magic};
const our $MIME_TYPE    => q{Mime-Type};
const our $ENCODING     => q{Encoding};
const our $CONTENT_SIZE => q{Content-Size};

# list of SHA digests
const our @SHA_ALGORITHMS => qw{SHA-256 SHA-384 SHA-512};

__PACKAGE__;
__END__
