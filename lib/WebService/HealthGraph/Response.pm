package WebService::HealthGraph::Response;

use Moo;

use JSON::MaybeXS qw( decode_json );
use Types::Standard qw( Bool InstanceOf Maybe Ref );

# records could be an ArrayRef. other than that, we should be mostly dealing
# with a HashRef

has content => (
    is      => 'ro',
    isa     => Maybe [Ref],
    lazy    => 1,
    builder => '_build_content',
);

has raw => (
    is      => 'ro',
    isa     => InstanceOf ['HTTP::Response'],
    handles => { code => 'code' },
);

has success => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    builder => '_build_success',
);

sub _build_content {
    my $self    = shift;
    my $content = $self->raw->decoded_content;

    return $content ? decode_json($content) : undef;
}

sub _build_success {
    my $self = shift;
    return $self->raw->is_success && !$self->raw->header('X-Died');
}

1;
__END__
# ABSTRACT: Generic response object for WebService::HealthGraph

=head2 content

Returns either a C<HashRef> or an C<ArrayRef> of the content, depending on what
the HealthGraph API returns.

=head2 raw

Returns the raw L<HTTP::Response> object.

=head2 success

Returns true if the HTTP request was fetched and parsed successfully.
