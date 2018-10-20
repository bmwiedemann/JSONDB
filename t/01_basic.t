#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 3;
require_ok 'JSONDB';

my $testdb="testdb.json";
unlink $testdb;
# write DB
my %hash;
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;
$hash{a}=27;
$hash{b}=28;
delete $hash{b};
untie %hash;

# read DB
my %hash2;
tie %hash2, 'JSONDB', $testdb, O_RDONLY;
is($hash2{a}, 27);
is($hash2{b}, undef);
