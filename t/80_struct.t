#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 5;
require_ok 'JSONDB';

$ENV{PATH}="/usr/bin";
my $testdb="testdb.json";
unlink $testdb;
# write DB
my %hash;
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;

# test that DB files can carry nested structs
$hash{a}={l2=>["nested", "array", 123, 2, {l3=>{l4=>4}}, {l3a=>[3,1]}, [4,2]], l2b=>{b=>7}, x=>6};
$hash{b}=[27, 5, {l2=>[3,1]}];
untie %hash;
is(substr(`md5sum $testdb`, 0, 32), "036d75dcc70456cf6141eb21a37be903");

my %hash2;
tie %hash2, 'JSONDB', $testdb, O_RDONLY, 0666;
is($hash2{a}{x}, 6);
is($hash2{a}{l2}[1], "array");
is($hash2{b}[2]{l2}[0], 3);
