# implement a simple database compatible to DB_File API
# that writes data as JSON to be agnostic of platform details
# written 2018 by Bernhard M. Wiedemann
# licensed under the same conditions as perl itself

package JSONDB;
use JSON::XS;
require Tie::Hash;
@ISA = qw(Tie::Hash);

sub diag(@) {print STDERR "@_\n"}

sub loadjson
{
    my $self=shift;
    open(my $f, "+<", $self->{file}) or die $!;
    local $/;
    $self->{data}=decode_json scalar <$f>;
}

sub storejson
{
    my $self=shift;
    open(my $f, "+>", $self->{file}) or die $!;
    print $f encode_json $self->{data};
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
        data=>{},
    );
    loadjson(\%x) if $mode == 0;
    bless \%x, $pkg ;
}

sub CLEAR
{
    diag "CLEAR @_";
    my $self=shift;
    $self->{data}={};
    $self->storejson();
}

sub DELETE
{
    diag "DELETE @_";
    my $self=shift;
    my ($key)=@_;
    delete $self->{data}->{$key};
    $self->storejson();
}

sub STORE
{
    diag "STORE @_";
    my $self=shift;
    my ($key,$value)=@_;
    $self->{data}->{$key}=$value;
    $self->storejson();
}

sub FETCH
{
    diag "FETCH @_";
    my $self=shift;
    my ($key)=@_;
    return $self->{data}->{$key};
}

sub EXISTS
{
    my ($self, $key) = @_;
    return exists $self->{data}->{$key};
}

sub SCALAR
{
    diag "SCALAR @_";
    my $self=shift;
    return %{$self->{data}};
}

sub FIRSTKEY
{
    my $self=shift;
    (keys(%{$self->{data}}))[0];
}

sub NEXTKEY
{
    my $self=shift;
    my $key=shift;
    my @keys=keys(%{$self->{data}});
    for(my $n=0; $n<=$#keys; ++$n) {
        if($keys[$n] eq $key) {
            return $keys[$n+1];
        }
    }
}

1;
