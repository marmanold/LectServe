package LectServe;

use v5.22;
use Dancer2;

use Time::Piece;
use Date::Lectionary;
use Date::Lectionary::Time qw(nextSunday);
use Date::Lectionary::Daily;

our $VERSION = '1.20170703';

get '/' => sub {
    send_as html => template 'index.tt';
};

get '/date/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as JSON => getLectionary( $date, query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

get '/today' => sub {
    send_as JSON =>
      getLectionary( cleanToday(), query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

get '/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );

    send_as JSON => getLectionary( $nextSunday, query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

get '/html/today' => sub {
    my $today = cleanToday();

    if ($today->fullday ne "Sunday") {
        my $dailyReadings = getDailyLectionary( $today, 'acna');

        send_as html => template 'daily_readings.tt', $dailyReadings;
    }
    else {
        my $lectHash = getLectionary( $today, query_parameters->get('lect') );

        send_as html => template 'readings.tt', $lectHash;
    }
};

get '/html/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );
    my $lectHash = getLectionary( $nextSunday, query_parameters->get('lect') );

    send_as html => template 'readings.tt', $lectHash;
};

get '/html/date/:day' => sub {
    my $day      = route_parameters->get('day');
    my $date     = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectHash = getLectionary( $date, query_parameters->get('lect') );

    send_as html => template 'readings.tt', $lectHash;
};

get '/html/about' => sub {
    send_as html => template 'about.tt';
};

sub getLectionary {
    my $day  = shift;
    my $lect = shift;

    my $lectionary;
    if ($lect) {
        $lectionary =
          Date::Lectionary->new( 'date' => $day, 'lectionary' => $lect );
    }
    else {
        $lectionary = Date::Lectionary->new( 'date' => $day );
    }

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

sub getDailyLectionary {
    my $day  = shift;
    my $lect = shift;

    my $lectionary = Date::Lectionary::Daily->new('date' => $day);

    return {
        date => $day->date, 
        lectionary => $lectionary->lectionary, 
        week => $lectionary->week, 
        readings => $lectionary->readings
    };
}

sub cleanToday {
    my $localTime = localtime;
    my $today     = $localTime->ymd;
    return Time::Piece->strptime( "$today", "%Y-%m-%d" );
}

true;
