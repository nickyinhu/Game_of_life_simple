use Life;
use Modern::Perl '2013';


my $life = Life->new(size => 15, sleep_time => 1);

$life->evolve;