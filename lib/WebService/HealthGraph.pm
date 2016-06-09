use strict;
use warnings;
package WebService::HealthGraph;

use Moo 2.001001;

use LWP::UserAgent 6.15 ();
use WebService::HealthGraph::Response ();
use Type::Tiny 1.000005;    # force minimum version
use Types::Standard qw( Bool HashRef InstanceOf Int Str );
use Types::URI qw( Uri );
use URI 1.71 ();

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

has url_map => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_url_map',
);

has user => (
    is      => 'ro',
    isa     => InstanceOf ['WebService::HealthGraph::Response'],
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

sub _build_url_map {
    my $self = shift;
    my %map  = %{ $self->user->{content} };
    delete $map{userID};
    return \%map;
}

sub _build_user {
    my $self = shift;
    return $self->get('/user');
}

sub get {
    my $self    = shift;
    my $url     = URI->new(shift);
    my $args    = shift;
    my $headers = $args->{headers} || {};
    my $feed    = $args->{feed} || 0;

    my $path = $url->path;

    $url->scheme( $self->base_url->scheme );
    $url->host( $self->base_url->host );

    my @path_parts = $url->path_segments;
    shift @path_parts;    # first part is empty string with an absolute URL
    my $top_level = shift @path_parts;

    my %type = (
        backgroundActivities       => 'BackgroundActivitySet',
        changeLog                  => 'ChangeLog',
        diabetes                   => 'DiabetesMeasurementSet',
        fitnessActivities          => 'FitnessActivity',
        generalMeasurements        => 'GeneralMeasurementSet',
        nutrition                  => 'NutritionSet',
        profile                    => 'Profile',
        records                    => 'Records',
        settings                   => 'Settings',
        sleep                      => 'SleepSet',
        strengthTrainingActivities => 'StrengthTrainingActivity',
        team                       => 'Team',
        user                       => 'User',
        weight                     => 'WeightSet',
    );

    unless ( exists $headers->{Accept} ) {
        my $accept = $type{$top_level};

        # Weird exception to the rule
        if ( @path_parts and $top_level eq 'team' ) {
            $accept = 'Member';
        }

        $accept .= 'Feed' if $feed;

        $headers->{Accept}
            = sprintf( 'application/vnd.com.runkeeper.%s+json', $accept );
    }

    my $res = $self->ua->get( $url, %{$headers} );
    return WebService::HealthGraph::Response->new( raw => $res );
}

1;

__END__
# ABSTRACT: A thin wrapper around the Runkeeper (Health Graph) API

=head1 DESCRIPTION

BETA BETA BETA.  The interface is subject to change.

This is a very thin wrapper around the Runkeeper (Health Graph) API.  At this
point it assumes that you already have an OAuth token to connect with.  You can
use L<Mojolicious::Plugin::Web::Auth::Site::Runkeeper> to create a token.  If
that doesn't suit you, patches to add OAuth token retrieval to this module will
be happily accepted.

=head1 SYNOPSIS

    my $graph = WebService::HealthGraph->new(
        debug => 1,
        token => 'foo',
    );

    my $user = $graph->user;

    use Data::Printer;
    p $user->content;

    # Fetch a weight feed

    use DateTime ();
    use URI::FromHash qw( uri );

    my $cutoff = DateTime->now->subtract( days => 7 );

    my $uri = uri(
        path  => '/weight',
        query => { noEarlierThan => $cutoff->ymd },
    );

    my $feed = $graph->get($uri, { feed => 1 });
    p $feed->content;

=head1 CONSTRUCTOR ARGUMENTS

=head2 base_url

The URL of the API.  Defaults to L<https://api.runkeeper.com>.  This is
settable in case you'd need this for mocking.

=head2 debug( $bool )

Turns on debugging via L<LWP::ConsoleLogger>.  Off by default.

=head2 token

OAuth token. Optional, but you'll need to to get any URLs.

=head2 ua

A user agent object of the L<LWP::UserAgent> family.  If you provide your own,
be sure you set the correct default headers required for authentication.

=head2 url_map

Returns a map of keys to URLs, as provided by the C<user> endpoint.  Runkeeper
wants you to use these URLs rather than constructing your own.

=head2 user

The L<WebService::HealthGraph::Response> object for the C<user> endpoint.

=head2 user_id

The id of the user as provided by the C<user> endpoint.

=head1 METHODS

=head2 get( $url, $optional_args )

This module will try to do the right thing with the minimum amount of
information:

    my $weight_response = $graph->get( 'weight', { feed => 1 } );
    if ( $weight_response->success ) {
        ...
    }

Optionally, you can provide your own Accept (or other) headers:

    my $record_response = $graph->get(
        'records',
        {
            headers =>
                { Accept => 'application/vnd.com.runkeeper.Records+json' }
        );

Returns a L<WebService::HealthGraph::Response> object.

=head1 CAVEATS

Most response content will contain a C<HashRef>, but the C<records> endpoint
returns a response with an C<ArrayRef> in the content.
