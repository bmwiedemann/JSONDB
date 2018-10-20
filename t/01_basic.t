#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 2;
require_ok 'JSONDB';

# write DB
my $testdb="testdb.json";
unlink $testdb;
my %hash;
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;
$hash{a}=27;
untie %hash;

# read DB
my %hash2;
tie %hash2, 'JSONDB', $testdb, O_RDONLY;
is($hash2{a}, 27);

