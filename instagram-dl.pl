#!/usr/bin/perl
### This Source Code Form is subject to the terms of the Mozilla Public
### License, v. 2.0. If a copy of the MPL was not distributed with this
### file, You can obtain one at http://mozilla.org/MPL/2.0/. */

###
### instagram-dl
### Download image file from an instagram link.
### Run using:
### instagram-dl <url>...
###
### Ex.
### ./instagram-dl https://www.instagram.com/p/BEZ0PHjtUhH/
###

use strict;
use warnings;
use 5.010;

#use HTTP::Tiny;
require "lib/HTTP/Tiny.pm";

my $tiny = HTTP::Tiny->new();

# Usage instructions
if (
	@ARGV == 0 ||
	(@ARGV == 1 && ($ARGV[0] eq '-h' || $ARGV[0] eq '-help' || $ARGV[0] eq '-?'))
) {
	print "\nUsage:\ninstagram-dl [-h] <url>... \n\n";
	exit 0;
}

for (@ARGV) {
	process_url($_);
}

sub process_url {
	my $url = shift;

	# Download page markup
	print "Accessing $url... ";
	my $resp = $tiny->get($url);
	die "Unable to access $url" unless $resp->{success};
	print "Done.\n";

	#
	# Extract image url from the following tag in page markup:
	# <meta property="og:image" content="..." />
	#
	my $content = $resp->{content};
	$content =~ /<meta property="og:image" content="(.*?)" \/>/s;
	my $image_url = $1;
	die "No image found in $url" unless defined $image_url;

	$image_url =~ /\/([^\/]+?\.jpg)/;
	my $image_filename = $1;
	die "Can't determine image filename" unless defined $image_filename;

	# Download image url and save to file.
	print "Downloading file '$image_filename'... ";
	$resp = $tiny->get($image_url);
	die "Unable to access $image_url" unless $resp->{success};

	open my $hout_image, '>', $image_filename
		or die "Unable to write to $image_filename: $!\n";
	binmode($hout_image);
	print $hout_image scalar $resp->{content};
	close $hout_image;
	print "Done.\n";
}


