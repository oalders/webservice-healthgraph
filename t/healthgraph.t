use Test2::Bundle::Extended;

use Test::RequiresInternet ('api.runkeeper.com' => 443);
use WebService::HealthGraph;

my $graph = WebService::HealthGraph->new( debug => 1 );
ok( $graph,           'compiles' );
ok( $graph->ua,       'ua' );
ok( $graph->base_url, 'base_url' );

my $user_response = $graph->user;
ok( $user_response, 'get_user' );
is( $user_response->code, 401, '401 response with missing token' );

done_testing;
