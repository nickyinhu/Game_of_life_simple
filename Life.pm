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
    my $current_state = $life_map->[$row]->[$col];

    my $neigbour_live_cells = 0;

    if ($row > 0) {
        if ($col > 0) {
            my $nw = $life_map->[$row-1]->[$col-1];
            $neigbour_live_cells++ if $nw == 1;
        }
        my $north = $life_map->[$row-1]->[$col];
        $neigbour_live_cells++ if $north == 1;
        if ($col < $size-1) {
            my $ne = $life_map->[$row-1]->[$col+1];
            $neigbour_live_cells++ if $ne == 1;
        }
    }
    if ($col > 0) {
        my $west = $life_map->[$row]->[$col-1];
        $neigbour_live_cells++ if $west == 1;
    }
    if ($col < $size-1) {
        my $east = $life_map->[$row]->[$col+1];
        $neigbour_live_cells++ if $east == 1;
    }
    if ($row < $size-1) {
        if ($col > 0) {
            my $sw = $life_map->[$row+1]->[$col-1];
            $neigbour_live_cells++ if $sw == 1;
        }
        my $south = $life_map->[$row+1]->[$col];
        $neigbour_live_cells++ if $south == 1;
        if ($col < $size-1) {
            my $se = $life_map->[$row+1]->[$col+1];
            $neigbour_live_cells++ if $se == 1;
        }
    }
    # say "$row $col: $current_state $neigbour_live_cells";
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
        @{$life_map->[$row]} = map {$_->state} @{$cell_row};
        $row++;
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