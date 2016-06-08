use Test2::Bundle::Extended;

use Data::Printer;
use Test::RequiresInternet ('api.runkeeper.com' => 443);
use URI::FromHash qw( uri );
use WebService::Runkeeper;

SKIP: {
    skip 'Token required for live tests', 1 unless $ENV{RUNKEEPER_TOKEN};

    my $rk = WebService::Runkeeper->new(
        debug => 1,
        token => $ENV{RUNKEEPER_TOKEN},
    );
    ok( $rk,           'compiles' );
    ok( $rk->ua,       'ua' );
    ok( $rk->base_url, 'base_url' );

    my $user = $rk->user;
    ok( $user,        'get_user' );
    ok( $rk->user_id, 'user_id' );

    diag np $user->content;
    my $query
        = { noEarlierThan => DateTime->now->subtract( days => 7 )->ymd };
    {
        my $uri = uri(
            path  => '/weight',
            query => $query,
        );

        my $feed = $rk->get($uri);
        ok( $feed, 'GET weight feed' );
        diag np $feed->content;
    }

    {
        my $uri = uri(
            path  => '/fitnessActivities',
            query => $query,
        );

        my $feed = $rk->get($uri);
        diag np $feed->content;
        ok( $feed, 'GET fitnessActivities feed' );

        if ( $feed->content->{items} ) {
            my $item = $rk->get( $feed->content->{items}[0]{uri} );
            diag( np( $item->content ) );
        }
    }
}

done_testing;
