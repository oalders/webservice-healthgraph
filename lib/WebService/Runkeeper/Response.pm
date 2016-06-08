package WebService::Runkeeper::Response;

use Moo;

use JSON::MaybeXS qw( decode_json );
use Types::Standard qw( HashRef InstanceOf Maybe );

has content => (
    is      => 'ro',
    isa     => Maybe [HashRef],
    lazy    => 1,
    builder => '_build_content',
);

has raw => (
    is      => 'ro',
    isa     => InstanceOf ['HTTP::Response'],
    handles => { code => 'code' },
);

sub _build_content {
    my $self    = shift;
    my $content = $self->raw->decoded_content;

    return $content ? decode_json($content) : undef;
}

1;
__END__
# ABSTRACT: Generic response object for WebService::Runkeeper
