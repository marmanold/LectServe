package LectServe;
use Dancer2;

use Date::Lectionary;
use Time::Piece;

our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    send_as html => template 'index.tt';
};

get '/date/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    return getLectionary($date);
};

get '/today' => sub {
    my $today = localtime;
    return getLectionary($today);
};

sub getLectionary {
    my $day = shift;
    my $lectionary = Date::Lectionary->new( 'date' => $day );

    my @services;

    if ( $lectionary->day->multiLect eq 'yes' ) {
        my $readings = $lectionary->readings;
        foreach my $lect (@$readings) {

            push( @services, $lect );
        }
    }
    else {
        my $lectInfo = {
            name     => $lectionary->day->name,
            alt      => $lectionary->day->alt,
            readings => $lectionary->readings,
        };

        push( @services, $lectInfo );
    }

    return {
        date       => $day->date,
        lectionary => $lectionary->lectionary,
        year       => $lectionary->year->name,
        services   => [@services],
    };
}

true;
