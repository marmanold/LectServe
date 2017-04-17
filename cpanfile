requires "Dancer2" => "0.205";
requires "Date::Lectionary" => "1.20161227";
requires "Time::Piece" => "1.31";
requires "Date::Lectionary::Time" => "1.20160809";
requires "Template" => "2.26";
requires "Plack" => "1.0043";
requires "Plack::Middleware::Deflater" => "0.12";
requires "Plack::Middleware::CrossOrigin" => "0.012";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
