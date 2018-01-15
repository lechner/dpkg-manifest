#!/usr/bin/perl
#
# Manifest::Write.pm
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


package Manifest::Write;

our $VERSION = 0;

use strict;
use warnings;

use feature qw(switch);
no if $] >= 5.018, warnings => "experimental::smartmatch";

use Exporter qw( import );
use Carp;

use Manifest::Fields;

our @EXPORT = qw(
  write_manifest
);

our @EXPORT_OK = qw();

sub print_field {
    my ( $hashref, $field, $specifier ) = @_;
    if ( defined $specifier ) {
        print "$field: $specifier $hashref->{$field}{$specifier}\n"
          if defined $hashref
          && defined $hashref->{$field}
          && defined $hashref->{$field}{$specifier};
    }
    else {
        print "$field: $hashref->{$field}\n"
          if defined $hashref && $hashref->{$field};
    }
    return;
}

sub print_included_file_field {
    my ( $include, $item, $field, $specifier ) = @_;
    print_field( $item, $field, $specifier )
      if $include->{ $item->{$FILE_TYPE} }{$field};
    return;
}

sub write_manifest {
    my ( $catalog, $include, $title, $extra_info ) = @_;

    my $tally = $catalog->{$TALLY};

    print "$MANIFEST_VERSION: 0\n";
    print "$TITLE: $title\n" if defined $title;

    foreach my $algorithm (@SHA_ALGORITHMS) {
        print_field( $catalog, $RUNNING_DIGEST, $algorithm );
    }

    foreach my $file_type (@FILE_TYPES) {
        if ( $tally->{$file_type} ) {
            my @fields_included = ();
            foreach my $field_name (@FIELD_NAMES) {
                if ( $include->{$file_type}{$field_name} ) {
                    push( @fields_included, $field_name );
                }
            }
            my $components = join( " ", @fields_included );
            print "$DIGEST_COMPONENTS: [$file_type] $components\n";
        }
    }

    if ($extra_info) {
        print "--- for information only ---\n";

        print "$TALLY: $ITEM ", scalar keys %{ $catalog->{$ITEM} }, "\n";

        foreach my $file_type (@FILE_TYPES) {
            print_field( $catalog, $TALLY, $file_type );
        }

        print_field( $catalog, $TALLY, $CONTENT_SIZE );
    }

    foreach my $catalogPath ( sort keys %{ $catalog->{$ITEM} } ) {

        my $item      = $catalog->{$ITEM}{$catalogPath};
        my $file_type = $item->{$FILE_TYPE};

        print "\n";

        foreach my $field_name (@FIELD_NAMES) {
            given ($field_name) {
                when ($PATH) {
                    print "$PATH: $catalogPath\n"
                      if $include->{$file_type}{$PATH};
                }
                when ($CONTENT) {
                    foreach my $algorithm (@SHA_ALGORITHMS) {
                        print_included_file_field( $include, $item, $CONTENT,
                            $algorithm );
                    }
                }
                default {
                    print_included_file_field( $include, $item, $field_name );
                }
            }
        }

        if ($extra_info) {
            print "--- for information only ---\n";

            given ( $item->{$FILE_TYPE} ) {
                when ($REGULAR) {
                    print_field( $item, $MAGIC );
                    print_field( $item, $MIME_TYPE );
                    print_field( $item, $ENCODING );
                    print_field( $item, $CONTENT_SIZE );
                }
                when ($LINK) {
                    print_field( $item, $CONTENT_SIZE );
                }
            }
        }
    }

    return;
}


__PACKAGE__;
__END__
