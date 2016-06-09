use Test2::Bundle::Extended;

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
    diag np $graph->url_map;

    my $query
        = { noEarlierThan => DateTime->now->subtract( days => 7 )->ymd };
    $query = {};

    # Test feeds
    foreach my $key ( sort keys %{ $graph->url_map } ) {
        next
            if any { $key eq $_ }
        (
            'change_log', 'diabetes', 'profile', 'records', 'settings',
            'team',
            'userID'
        );

        my $uri = uri(
            path  => $user->content->{$key},
            query => $query,
        );

        my $feed = $graph->get( $uri, { feed => 1 } );
        ok( $feed,          "GET $uri" );
        ok( $feed->success, '200 code' );
        diag np $feed->content;

    }
}

done_testing;
