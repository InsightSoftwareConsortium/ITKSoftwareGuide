#!/usr/bin/perl
#
#  Script for searching for double words in the text
#
#  Contributed by Hans Johnson,  Iowa University
#

$/ = ".\n";
while (<>) {
 next if !s/\b([a-z]+)((\s|<[^>]+>)+)(\1\b)/\e[7m$1\e[m$2\e[7m$4\e[m/ig;
 s/^([^\e]*\n)+//mg;
 s/^/$ARGV: /mg;
 print;
} 

