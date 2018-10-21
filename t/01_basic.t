#!perl -T
package BasicTests;
use strict;
use warnings;
use lib '.';
use Fcntl;
use Test::More tests => 9;
require_ok 'JSONDB';

my $testdb="testdb.json";
unlink $testdb;
# write DB
my %hash;
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;
%hash=();
$hash{a}=27;
$hash{b}=28;
$hash{c}=5;
untie %hash;
# rewrite
tie %hash, 'JSONDB', $testdb, O_CREAT|O_RDWR, 0666;
delete $hash{b};
untie %hash;

# read DB
my %hash2;
tie %hash2, 'JSONDB', $testdb, O_RDONLY;
is(exists($hash2{a}), 1);
is(exists($hash2{b}), '');
is($hash2{a}, 27);
is($hash2{b}, undef);
is(keys(%hash2), 2);
is(join(",", sort(keys(%hash2))), "a,c");

my $out = eval{tie %hash2, 'JSONDB', $testdb."-missing", O_RDONLY};
is($out, undef);
like($@, qr/failed to load $testdb-missing: No such file or directory at JSONDB.pm line /);
