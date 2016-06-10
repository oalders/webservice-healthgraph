use Test2::Bundle::Extended;

use Test::RequiresInternet ( 'api.runkeeper.com' => 443 );
use WebService::HealthGraph;

my $runkeeper = WebService::HealthGraph->new( debug => 1 );
ok( $runkeeper,           'compiles' );
ok( $runkeeper->ua,       'ua' );
ok( $runkeeper->base_url, 'base_url' );

my $user_response = $runkeeper->user;
ok( $user_response, 'get_user' );
is( $user_response->code, 401, '401 response with missing token' );

done_testing;
