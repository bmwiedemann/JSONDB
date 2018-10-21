#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 2;
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

is(substr(`md5sum $testdb`, 0, 32), "036d75dcc70456cf6141eb21a37be903");
