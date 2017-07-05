package Cell;
use Modern::Perl '2013';
use Moose;

has 'state' => (
    is => 'rw',
    isa => 'Bool',
    traits  => [qw/Bool/],
    default => 0,
    handles => {
        live  => 'set',
        dead => 'unset',
    },
);

1;