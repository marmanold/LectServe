requires "Dancer2" => "0.205";
requires "Date::Lectionary" => "1.20161227";
requires "Time::Piece" => "1.31";
requires "Date::Lectionary::Time" => "1.20160809";
requires "Template" => "2.26";

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
