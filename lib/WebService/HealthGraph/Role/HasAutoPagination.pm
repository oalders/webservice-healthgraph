package WebService::HealthGraph::Role::HasAutoPagination;

use Moo::Role;

use Types::Standard qw( Bool );

has auto_pagination => (
    is      => 'ro',
    isa     => Bool,
    default => 1,
);

1;
