# NAME

WebService::HealthGraph - A thin wrapper around the Runkeeper (Health Graph) API

[![Build Status](https://travis-ci.org/oalders/webservice-healthgraph.png?branch=master)](https://travis-ci.org/oalders/webservice-healthgraph)

# VERSION

version 0.000004

# SYNOPSIS

    my $runkeeper = WebService::HealthGraph->new(
        debug => 1,
        token => 'foo',
    );

    my $user = $runkeeper->user;

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

    my $feed = $runkeeper->get($uri, { feed => 1 });
    p $feed->content;

# DESCRIPTION

BETA BETA BETA.  The interface is subject to change.

This is a very thin wrapper around the Runkeeper (Health Graph) API.  At this
point it assumes that you already have an OAuth token to connect with.  You can
use [Mojolicious::Plugin::Web::Auth::Site::Runkeeper](https://metacpan.org/pod/Mojolicious::Plugin::Web::Auth::Site::Runkeeper) to create a token.  If
that doesn't suit you, patches to add OAuth token retrieval to this module will
be happily accepted.

# CONSTRUCTOR ARGUMENTS

## auto\_pagination

Boolean.  If enabled, response objects will continue to fetch new result pages
as the iterator requires them.  Defaults to true.

## base\_url

The URL of the API.  Defaults to [https://api.runkeeper.com](https://api.runkeeper.com).  This is
settable in case you'd need this for mocking.

## debug( $bool )

Turns on debugging via [LWP::ConsoleLogger](https://metacpan.org/pod/LWP::ConsoleLogger).  Off by default.

## token

OAuth token. Optional, but you'll need to to get any URLs.

## ua

A user agent object of the [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) family.  If you provide your own,
be sure you set the correct default headers required for authentication.

## url\_map

Returns a map of keys to URLs, as provided by the `user` endpoint.  Runkeeper
wants you to use these URLs rather than constructing your own.

## uri\_for

Gives you the corresponding url (in the form of an [URI](https://metacpan.org/pod/URI) object) for any key
which exists in `url_map`.  You can optionally pass a HashRef of query params
to this method.

    my $team_uri =  $runkeeper->uri_for( 'team', { pageSize => 10 } );

    my $friends = $runkeeper->get(
        $runkeeper->uri_for( 'team', { pageSize => 10 } ),
        { feed => 1 }
    );

## url\_for

Convenience method which points to `url_for`.  Will be removed in a later
release.

## user

The [WebService::HealthGraph::Response](https://metacpan.org/pod/WebService::HealthGraph::Response) object for the `user` endpoint.

## user\_id

The id of the user as provided by the `user` endpoint.

# METHODS

## get( $url, $optional\_args )

This module will try to do the right thing with the minimum amount of
information:

    my $weight_response = $runkeeper->get( 'weight', { feed => 1 } );
    if ( $weight_response->success ) {
        ...
    }

Optionally, you can provide your own Accept (or other) headers:

    my $record_response = $runkeeper->get(
        'records',
        {
            headers =>
                { Accept => 'application/vnd.com.runkeeper.Records+json' }
        );

Returns a [WebService::HealthGraph::Response](https://metacpan.org/pod/WebService::HealthGraph::Response) object.

# CAVEATS

Most response content will contain a `HashRef`, but the `records` endpoint
returns a response with an `ArrayRef` in the content.

# AUTHOR

Olaf Alders <olaf@wundercounter.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Olaf Alders.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
