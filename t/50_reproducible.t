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

my $n=0;
# test that DB files have reproducible output
for("a".."z") {
    $hash{$_}=$n++;
}
is(substr(`md5sum $testdb`, 0, 32), "3f652e87cea7c55b8c77ecba966b7480");
