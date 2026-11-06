#!/usr/bin/perl
#
# file truncation script
# first argument indicates the absolute file path
# second argument indicates the number of bytes
#  
$target=$ARGV[0];
$bytes=$ARGV[1];
truncate $target, $bytes;