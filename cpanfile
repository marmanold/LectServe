requires "perl", "5.26.0";

requires "Dancer2" => "0.206000";
requires "Dancer2::Plugin::HTTP::Caching" => "0.01";
requires "Time::Piece" => "1.3204";
requires "Time::Seconds" => "1.3204";
requires "Template" => "2.26";
requires "Template::Plugin::Date" => "2.78";
requires "Plack" => "1.0045";
requires "Plack::Middleware::Deflater" => "0.12";
requires "Plack::Middleware::CrossOrigin" => "0.012";
requires "Carp" => "1.38";
requires "Try::Catch" => "1.1.0";
requires "Module::Version" => "0.12";
requires "Starman" => "0.4014";
requires "Try::Tiny::Tiny" => "0.001";
requires "Date::Advent" => "1.20180423";
requires "Date::Lectionary::Time" => "1.20180422.1";
requires "Date::Lectionary" => "1.20190120";
requires "Date::Lectionary::Daily" => "1.20180423";
requires "REST::Client" => "88";
requires "Text::Trim" => "1.02";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0.17";
recommends "HTTP::XSCookies"  => "0";
recommends "Scope::Upper"     => "0";
recommends "Type::Tiny::XS"   => "0";

on "test" => sub {
    requires     "Test::More"            => "1.302040";
    requires     "Test::DistManifest"    => "1.014";
    requires     "Test::Exception"       => "0.43";
    requires     "Pod::Markdown"         => "3.005";
    requires     "Test::Pod"             => "1.51";
    requires     "Test::Pod::Coverage"   => "1.10";
    requires     "Test::MinimumVersion"  => "0.101082";
    requires     "Test::Kwalitee::Extra" => "0.4.0";
    requires     "Test::Kwalitee"        => "1.27";
    requires     "Test::CPAN::Changes"   => "0.400002";
    requires     "Test::Version"         => "2.07";
};
