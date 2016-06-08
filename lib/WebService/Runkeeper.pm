use strict;
use warnings;
package WebService::Runkeeper;

use Moo;

use Compress::Zlib qw( memGunzip );
use JSON::MaybeXS qw( decode_json );
use LWP::UserAgent                  ();
use WebService::Runkeeper::Response ();
use Types::Standard qw( Bool HashRef InstanceOf Int Str );
use Types::URI qw( Uri );
use URI ();

has base_url => (
    is      => 'ro',
    isa     => InstanceOf ['URI'],
    lazy    => 1,
    default => sub { URI->new('https://api.runkeeper.com') },
    coerce  => 1,
);

has debug => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has token => (
    is        => 'ro',
    isa       => Str,
    predicate => '_has_token',
);

has ua => (
    is      => 'ro',
    isa     => InstanceOf ['LWP::UserAgent'],
    lazy    => 1,
    builder => '_build_ua',
);

has user => (
    is      => 'ro',
    isa     => InstanceOf ['WebService::Runkeeper::Response'],
    lazy    => 1,
    builder => '_build_user',
);

has user_id => (
    is      => 'ro',
    isa     => Int,
    lazy    => 1,
    default => sub { shift->user->content->{userID} },
);

sub _build_ua {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    if ( $self->_has_token ) {
        $ua->default_header( Authorization => 'Bearer ' . $self->token );
    }

    return $ua unless $self->debug;
    require LWP::ConsoleLogger::Easy;
    LWP::ConsoleLogger::Easy::debug_ua($ua);
    return $ua;
}

sub _build_user {
    my $self = shift;
    return $self->get('/user');
}

sub get {
    my $self    = shift;
    my $url     = URI->new(shift);
    my $headers = shift || {};

    my $path = $url->path;

    $url->scheme( $self->base_url->scheme );
    $url->host( $self->base_url->host );

    my @path_parts = $url->path_segments;
    shift @path_parts; # first part is empty string with an absolute URL
    my $top_level  = $path_parts[0];

    my %type = (
        fitnessActivities => 'FitnessActivity',
        user              => 'User',
        weight            => 'WeightSet',
    );

    unless ( exists $headers->{Accept} ) {
        my $accept = $type{$top_level};

        # Distinguish between fetching a single item and a feed of items.
        unless ( $top_level eq 'user' ) {
            unless ( scalar @path_parts > 1 ) {
                $accept .= 'Feed';
            }
        }

        $headers->{Accept}
            = sprintf( 'application/vnd.com.runkeeper.%s+json', $accept );
    }

    my $res = $self->ua->get( $url, %{$headers} );
    return WebService::Runkeeper::Response->new( raw => $res );
}

1;
