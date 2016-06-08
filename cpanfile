requires "Compress::Zlib" => "0";
requires "JSON::MaybeXS" => "0";
requires "LWP::ConsoleLogger::Easy" => "0";
requires "LWP::UserAgent" => "0";
requires "Moo" => "0";
requires "Types::Standard" => "0";
requires "Types::URI" => "0";
requires "URI" => "0";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "Data::Printer" => "0";
  requires "Test2::Bundle::Extended" => "0";
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
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Spelling" => "0.12";
  requires "Test::Synopsis" => "0";
};