#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 4;
require_ok 'JSONDB';

$ENV{PATH}="/usr/bin";
my $testdb="testdb.json";
unlink $testdb;
# write DB
my %hash;
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;

# test that DB files can carry arbitrary bytes
my $binstr="\x00\n\"\\\xff\xc0";
$hash{a}=$binstr;
$hash{$binstr}="foo";
untie %hash;
is(substr(`md5sum $testdb`, 0, 32), "32dca037aae26fb03390250455f5e6a5");

my %hash2;
tie %hash2, 'JSONDB', $testdb, O_RDONLY, 0666;
is($hash2{a}, $binstr);
is($hash2{$binstr}, "foo");
