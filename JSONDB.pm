# implement a simple database compatible to DB_File API
# that writes data as JSON to be agnostic of platform details
# written 2018 by Bernhard M. Wiedemann
# licensed under the same conditions as perl itself

package JSONDB;
use JSON::XS;
require Tie::Hash;
@ISA = qw(Tie::ExtraHash);

#sub diag(@) {print STDERR "@_\n"}
sub diag(@) {}

our $coder = JSON::XS->new->pretty->canonical;

sub loadjson
{
    my $self=shift;
    open(my $f, "+<", $self->[1]{file}) or die $!;
    local $/;
    $self->[0]=decode_json scalar <$f>;
}

sub storejson
{
    my $self=shift;
    open(my $f, "+>", $self->[1]{file}) or die $!;
    print $f $coder->encode($self->[0]);
}

sub TIEHASH
{
    diag "TIEHASH @_";
    my $pkg = shift;
    my ($filename, $mode, $umask) = @_;
    $umask //= 0666;
    my %x=(
        file=>$filename,
        mode=>$mode,
        umask=>$umask,
    );
    my $storage = bless [{}, \%x], $pkg;
    loadjson($storage) if $mode == 0;
    return $storage;
}

sub CLEAR
{
    diag "CLEAR @_";
    my $self=shift;
    $self->SUPER::CLEAR(@_);
    $self->storejson();
}

sub DELETE
{
    diag "DELETE @_";
    my $self=shift;
    $self->SUPER::DELETE(@_);
    $self->storejson();
}

sub STORE
{
    diag "STORE @_";
    my $self=shift;
    $self->SUPER::STORE(@_);
    $self->storejson();
}

1;
