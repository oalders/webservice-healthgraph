use Test2::Bundle::Extended;

use Test::RequiresInternet ('api.runkeeper.com' => 443);
use WebService::Runkeeper;

my $rk = WebService::Runkeeper->new( debug => 1 );
ok( $rk,           'compiles' );
ok( $rk->ua,       'ua' );
ok( $rk->base_url, 'base_url' );

my $user_response = $rk->user;
ok( $user_response, 'get_user' );
is( $user_response->code, 401, '401 response with missing token' );

done_testing;
