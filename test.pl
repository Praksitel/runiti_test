use strict;
use warnings FATAL => 'all';
use Data::Dumper;

my @paths = (
    '/api/v1/:storage/:pk/raw',
    '/api/v1/:storage/:pk/:op',
    '/api/v1/:storage/:pk',
);

my $url = 'http://localhost:8080/api/v1/order/123/update';
my ($paths, $i) = ({}, 0);

for my $path (@paths) {
    my @arr = split('/', $path);
    my $y = 0;
    my @key_indexes = ();
    for my $elem (@arr) {
        next if $elem eq '';
        if ($elem =~ /^:(\S+)/) {
            $paths->{$i}->{$y} = $elem;
            $elem = q/(\S+)/;
            push @key_indexes, $y;
        }
        ++$y;
    }
    $paths->{$i}->{url} = $path;
    $paths->{$i}->{re} = join('/', @arr);
    $paths->{$i}->{key_indexes} = \@key_indexes;
    ++$i;
}
test($url);

$url = "http://";
test($url);

$url = "http://localhost:8080/api/v1/order/123/raw";
test($url);


sub check {
    my $url = shift;
    my $compared_index;
    for $i (0..$#paths) {
        if (my (@params) = $url =~ m/$paths->{$i}->{re}/) {
            $paths->{$i}->{eq} = $url;
            for my $j (0..$#params) {
                $paths->{$i}->{params}->{$paths->{$i}->{$paths->{$i}->{key_indexes}->[$j]}} = $params[$j];
            }
            $compared_index = $i;
            last;
        }
    }
    return $compared_index;
}

sub test {
    my $url = shift;
    my $compared_index = check($url);

    print "\ntest url: $url";
    if (defined $compared_index) {
        print "\nCompared index: $compared_index";
        print "\nCompared params: " . Dumper $paths->{$compared_index};
    } else {
        print "\nurl: $url has no match";
    }
}