requires 'perl', '5.22.0';

requires "Dancer2" => "0.205";
requires "Date::Lectionary" => "1.20180109";
requires "Time::Piece" => "1.31";
requires "Time::Seconds" => "1.3201";
requires "Date::Lectionary::Time" => "1.20170311";
requires "Date::Lectionary::Daily" => "1.20180204";
requires "Template" => "2.26";
requires "Template::Plugin::Date" => "2.78";
requires "Plack" => "1.0043";
requires "Plack::Middleware::Deflater" => "0.12";
requires "Plack::Middleware::CrossOrigin" => "0.012";
requires "Carp" => "1.38";
requires "Try::Tiny" => "0.24";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
