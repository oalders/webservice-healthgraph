package WebService::HealthGraph::Response;

use Moo;

use Array::Iterator ();
use JSON::MaybeXS qw( decode_json );
use Types::Standard qw( Bool CodeRef InstanceOf Maybe Ref );
use Types::URI qw( Uri );

# records could be an ArrayRef. other than that, we should be mostly dealing
# with a HashRef

has auto_pagination => (
    is      => 'ro',
    isa     => Bool,
    default => 1,
);

has content => (
    is      => 'ro',
    isa     => Maybe [Ref],
    lazy    => 1,
    clearer => '_clear_content',
    builder => '_build_content',
);

has _get => (
    is       => 'ro',
    isa      => CodeRef,
    required => 1,
    init_arg => 'get',
);

has _iterator => (
    is      => 'ro',
    isa     => InstanceOf ['Array::Iterator'],
    clearer => '_clear_iterator',
    builder => '_build_iterator',
    lazy    => 1,
);

has next_page_uri => (
    is      => 'ro',
    isa     => Maybe [Uri],
    clearer => '_clear_next_page_uri',
    coerce  => 1,
    lazy    => 1,
    default => sub { $_[0]->content ? $_[0]->content->{next} : undef },
);

has raw => (
    is       => 'ro',
    isa      => InstanceOf ['HTTP::Response'],
    handles  => { code => 'code' },
    required => 1,
    clearer  => '_clear_raw',
    writer   => '_set_raw',
);

has success => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    clearer => '_clear_success',
    builder => '_build_success',
);

sub _build_content {
    my $self    = shift;
    my $content = $self->raw->decoded_content;

    return $content ? decode_json($content) : undef;
}

sub _build_iterator {
    my $self    = shift;
    my $content = $self->content->{items};
    $content = [$content] unless ref $content eq 'ARRAY';
    return Array::Iterator->new($content);
}

sub _build_success {
    my $self = shift;
    return $self->raw->is_success && !$self->raw->header('X-Died');
}

sub next {
    my $self = shift;
    my $row  = $self->_iterator->get_next;
    return $row if $row;
    if ( $self->auto_pagination ) {
        my $result = $self->_next_page;
        return unless $result;
        $self->_reset;
        $self->_set_raw( $result->raw );
        return $self->_iterator->get_next;
    }
    return;
}

sub _next_page {
    my $self = shift;
    return unless $self->next_page_uri;
    return $self->_get->( $self->next_page_uri );
}

sub _reset {
    my $self = shift;
    $self->_clear_raw;
    $self->_clear_success;
    $self->_clear_content;
    $self->_clear_iterator;
    $self->_clear_next_page_uri;
}

1;
__END__
# ABSTRACT: Generic response object for WebService::HealthGraph

=head1 CONSTRUCTOR

=head2 new

Creates a new object.

=over

=item auto_pagination

Boolean.  If enabled, this object will continue to fetch new result pages as
the iterator requires them.  Defaults to true.

=back

=head2 content

Returns either a C<HashRef> or an C<ArrayRef> of the content, depending on what
the HealthGraph API returns.

=head2 next

This method iterates over the items in the response content, returning one
HashRef at a time.

=head2 next_page_uri

Returns the URL of the next page of results, in the form of a L<URI> object.
Returns C<undef> if there is no next page.

=head2 raw

Returns the raw L<HTTP::Response> object.

=head2 success

Returns true if the HTTP request was fetched and parsed successfully.
