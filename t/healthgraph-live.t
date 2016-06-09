use Test2::Bundle::Extended;
use Test2::Plugin::BailOnFail;

use Data::Printer;
use List::AllUtils qw( any );
use Test::RequiresInternet ( 'api.runkeeper.com' => 443 );
use URI::FromHash qw( uri );
use WebService::HealthGraph;

SKIP: {
    skip 'Token required for live tests', 1 unless $ENV{RUNKEEPER_TOKEN};

    my $graph = WebService::HealthGraph->new(
        debug => 1,
        token => $ENV{RUNKEEPER_TOKEN},
    );
    ok( $graph,           'compiles' );
    ok( $graph->ua,       'ua' );
    ok( $graph->base_url, 'base_url' );

    my $user = $graph->user;
    ok( $user,           'get_user' );
    ok( $graph->user_id, 'user_id' );
    ok( $graph->url_map, 'url_map' );

    my @non_feeds = ( 'change_log', 'profile', 'settings', 'records', );

    # Test feeds
    my $query
        = { noEarlierThan => DateTime->now->subtract( days => 7 )->ymd };
    foreach my $key ( sort keys %{ $graph->url_map } ) {
        next if any { $key eq $_ } ( @non_feeds, 'diabetes', 'team' );

        my $uri = uri( path => $user->content->{$key}, query => $query, );

        my $feed = $graph->get( $uri, { feed => 1 } );
        ok( $feed,          "GET $uri" );
        ok( $feed->success, '200 code' );

        if ( @{ $feed->content->{items} } ) {
            my $uri  = $feed->content->{items}->[0]->{uri};
            my $item = $graph->get($uri);
            ok( $item->success, "GET $uri" );
        }
    }

    foreach my $type (@non_feeds) {
        my $res = $graph->get( $graph->url_map->{$type} );
        ok( $res->success, $type );
    }
}

done_testing;
