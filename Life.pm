package Life;

use Modern::Perl '2013';
use Moose;
use DDP;
use Cell;

has 'size' => (
    is => 'rw',
    isa => 'Int',
    default => 5,
);

has 'sleep_time' => (
    is => 'rw',
    isa => 'Num',
    default => 2,
);

has 'cells' => (
    is => 'rw',
    isa => 'ArrayRef[ArrayRef[Cell]]',
    default => sub { [] },
);

has 'generation' => (
    traits  => ['Counter'],
    is      => 'ro',
    isa     => 'Num',
    default => 1,
    handles => {
        inc_generation   => 'inc',
        dec_generation   => 'dec',
        reset_generation => 'reset',
    },
);


sub BUILD {
    my $self = shift;

    my $size = $self->size;

    if ($size < 5) {
        die "Life size must be bigger than 5";
    }

    for (1..$size) {
        my $cells = [];
        for (1..$size) {
            my $cell = Cell->new();
            push @$cells, $cell;
        }
        push @{$self->cells}, $cells;
    }
    $self->init;
}

sub init {
    my $self = shift;
    my $args = shift;

    my $cells = $self->cells;

    $cells->[0][1]->live;
    $cells->[1][2]->live;
    $cells->[2][2]->live;
    $cells->[2][1]->live;
    $cells->[2][0]->live;
}

sub evolve {
    my $self = shift;

    my $size = $self->size;


    while (1) {
        my $life_map = $self->_get_current_life_map;
        $self->view;
        for my $row (0..($size-1)) {
            for my $col (0..($size-1)) {
                $self->_populate_cell($life_map, $row, $col);
            }
        }
        sleep $self->sleep_time;
    }
}

sub _populate_cell {
    my $self = shift;
    my $life_map = shift;
    my $row = shift;
    my $col = shift;
    my $size = $self->size;
    my $cells = $self->cells;
    my $current_state = $life_map->{"$row\|$col"}->{state};
    my $neigbour_live_cells = $life_map->{"$row\|$col"}->{neigbour_live_cells};

    if ($current_state == 0) {
        if ($neigbour_live_cells == 3) {
            $cells->[$row]->[$col]->live;
        }
    } else {
        if ($neigbour_live_cells < 2 || $neigbour_live_cells > 3) {
            $cells->[$row]->[$col]->dead;
        }
    }
}

sub _get_current_life_map {
    my $self = shift;
    my $cells = $self->cells;

    my $life_map;
    my $row = 0;
    for my $cell_row (@$cells) {
        my $col = 0;
        for my $cell (@$cell_row) {
            $life_map->{"$row\|$col"}->{state} = $cell->state;
            $life_map->{"$row\|$col"}->{neigbour_live_cells} = 0;
            $col++;
        }
        $row++;
    }
    for my $key (keys %$life_map) {
        my ($row,$col) = split(/\|/, $key);
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row-1) . '|' . ($col-1)}
                                                          && $life_map->{($row-1) . '|' . ($col-1)}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row-1) . '|' . $col}
                                                          && $life_map->{($row-1) . '|' . $col}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row-1) . '|' . ($col+1)}
                                                          && $life_map->{($row-1) . '|' . ($col+1)}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{$row . '|' . ($col-1)}
                                                          && $life_map->{$row . '|' . ($col-1)}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{$row . '|' . ($col+1)}
                                                          && $life_map->{$row . '|' . ($col+1)}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row+1) . '|' . ($col-1)}
                                                          && $life_map->{($row+1) . '|' . ($col-1)}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row+1) . '|' . $col}
                                                          && $life_map->{($row+1) . '|' . $col}->{state};
        $life_map->{$key}->{neigbour_live_cells}++ if exists $life_map->{($row+1) . '|' . ($col+1)}
                                                          && $life_map->{($row+1) . '|' . ($col+1)}->{state};
    }
    return $life_map;
}

sub view {
    my $self = shift;
    my $size = $self->size;
    my $cells = $self->cells;
    my $generation = $self->generation;
    say "============= $generation Generation =============";

    for my $row (0..($size-1)) {
        for my $col (0..($size-1)) {
            my $cell = $cells->[$row]->[$col];
            if ($cell->state) {
                print '#';
            } else {
                print 'o';
            }
            print ' ';
        }
        print "\n";
    }
    $self->inc_generation;
}

1;