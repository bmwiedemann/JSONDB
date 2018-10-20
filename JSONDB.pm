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

sub DELETE
{
    diag "DELETE";
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

1;
