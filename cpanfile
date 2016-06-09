requires "Compress::Zlib" => "0";
requires "JSON::MaybeXS" => "1.003005";
requires "LWP::ConsoleLogger::Easy" => "0";
requires "LWP::UserAgent" => "6.15";
requires "List::AllUtils" => "0";
requires "Moo" => "2.001001";
requires "Type::Tiny" => "1.000005";
requires "Types::Standard" => "0";
requires "Types::URI" => "0";
requires "URI" => "1.71";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Data::Printer" => "0";
  requires "Test2::Bundle::Extended" => "0";
  requires "Test2::Plugin::BailOnFail" => "0";
  requires "Test::RequiresInternet" => "0";
  requires "URI::FromHash" => "0";
  requires "perl" => "5.006";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "Module::Build" => "0.28";
  requires "perl" => "5.006";
};

on 'develop' => sub {
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::Spelling" => "0.12";
  requires "Test::Synopsis" => "0";
};
