# SPDX-License-Identifier: GPL-1.0-or-later

# implement a simple database compatible to DB_File API
# that writes data as JSON to be agnostic of platform details
# written 2018 by Bernhard M. Wiedemann
# licensed under the same conditions as perl itself

package JSONDB;
require JSON::XS;
require Tie::Hash;
@ISA = qw(Tie::ExtraHash);

our $coder = JSON::XS->new->ascii->pretty->canonical;

sub loadjson
{
    my $self=shift;
    open(my $f, "<", $self->[1]{file}) or return undef;
    local $/;
    $self->[0]=$coder->decode(<$f>);
}

sub storejson
{
    my $self=shift;
    open(my $f, ">", $self->[1]{file}) or die $!;
    print $f $coder->encode($self->[0]);
}

sub TIEHASH
{
    my $pkg = shift;
    my ($filename, $mode) = @_;
    my %x=(
        file=>$filename,
        mode=>$mode,
    );
    my $self = bless [{}, \%x], $pkg;
    if(!$self->loadjson && $mode == 0) {
        die "failed to load $filename: $!";
    }
    return $self;
}

sub CLEAR
{
    my $self=shift;
    $self->SUPER::CLEAR(@_);
    $self->storejson();
}

sub DELETE
{
    my $self=shift;
    $self->SUPER::DELETE(@_);
    $self->storejson();
}

sub STORE
{
    my $self=shift;
    $self->SUPER::STORE(@_);
    $self->storejson();
}

1;
