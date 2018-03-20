requires 'perl', '5.26.0';

requires "Dancer2" => "0.205002";
requires "Dancer2::Plugin::HTTP::Caching" => "0.01";
requires "Date::Lectionary" => "1.20180314";
requires "Time::Piece" => "1.3204";
requires "Time::Seconds" => "1.3204";
requires "Date::Lectionary::Time" => "1.20170311";
requires "Date::Lectionary::Daily" => "1.20180316";
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

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0.17";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
