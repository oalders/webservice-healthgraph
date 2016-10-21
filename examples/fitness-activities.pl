#!/usr/bin/env perl

use strict;
use warnings;

use Data::Printer;
use DateTime ();
use URI::FromHash qw( uri );
use WebService::HealthGraph ();

my $runkeeper = WebService::HealthGraph->new(
    debug => 1,
    token => $ENV{HEALTHGRAPH_TOKEN},
);

# Fetch an activities feed
my $cutoff = DateTime->now->subtract( days => 28 );

my $uri = $runkeeper->uri_for(
    'fitness_activities',
    { noEarlierThan => $cutoff->ymd, pageSize => 1, },
);

my $feed = $runkeeper->get( $uri, { feed => 1 } );
my $activity = $runkeeper->get( $feed->next->{uri} );
p $activity->content;
