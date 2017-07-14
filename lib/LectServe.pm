package LectServe;

use v5.22;
use Dancer2;

use Carp;
use Try::Tiny;

use Time::Piece;
use Time::Seconds;
use Date::Lectionary;
use Date::Lectionary::Time qw(nextSunday prevSunday);
use Date::Lectionary::Daily;

our $VERSION = '1.20170713';

#Root HTML Endpoints
get '/' => sub {
    my $today = cleanToday();
    my $lectionary = getAllLectionary( $today, 'acna');

    send_as html => template 'index.tt', $lectionary;
};

get '/home/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary = getAllLectionary( $date, 'acna');

    send_as html => template 'index.tt', $lectionary;
};

#JSON Endpoints
get '/date/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as JSON => getAllLectionary( $date, query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

get '/today' => sub {
    send_as JSON =>
      getAllLectionary( cleanToday(), query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

get '/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );

    send_as JSON => getSundayLectionary( $nextSunday, query_parameters->get('lect') ), {content_type=>'application/json; charset=UTF-8'};
};

#Daily Lectionary HTML Endpoints
get '/html/today' => sub {
    my $today = cleanToday();
    my $dailyReadings = getDailyLectionary( $today, 'acna');

    send_as html => template 'daily_readings.tt', $dailyReadings;
};

get '/html/daily/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary = getDailyLectionary( $date, 'acna');

    send_as html => template 'daily_readings.tt', $lectionary;
};

#Sunday Lectionary HTLM Endpoints
get '/html/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );
    my $lectHash = getSundayLectionary( $nextSunday, query_parameters->get('lect') );

    send_as html => template 'sunday_readings.tt', $lectHash;
};

get '/html/sunday/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary = getSundayLectionary( $date, query_parameters->get('lect'));

    send_as html => template 'sunday_readings.tt', $lectionary;
};

#Additional HTML Endpoints
get '/html/about' => sub {
    send_as html => template 'about.tt';
};

get '/api' => sub {
    send_as html => template 'api.tt';
};

#Helpter Methods used in resolving routes
sub getAllLectionary {
    my $day = shift;
    my $lect = shift;

    my $nextSunday = nextSunday($day);

    return {
        sunday => getSundayLectionary($nextSunday, $lect), 
        daily => getDailyLectionary($day, $lect)
    };
}

sub getSundayLectionary {
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
        nextSunday => nextSunday($day)->date,
        prevSunday => prevSunday($day)->date
    };
}

sub getDailyLectionary {
    my $day  = shift;
    my $lect = shift;

    my $lectionary = Date::Lectionary::Daily->new('date' => $day);

    return {
        date => $day->date, 
        day => $day->fullday, 
        date_pretty => $day->day_of_month . '. ' . $day->fullmonth . ' ' . $day->year, 
        lectionary => $lectionary->lectionary, 
        week => $lectionary->week, 
        readings => $lectionary->readings, 
        tomorrow => nextDay($day), 
        yesterday => prevDay($day)
    };
}

sub cleanToday {
    my $localTime = localtime;
    my $today     = $localTime->ymd;
    return Time::Piece->strptime( "$today", "%Y-%m-%d" );
}

sub nextDay {
    my ( $class, @params ) = @_;
    my $date = $params[0] // $class;
    my $tomorrow = undef;

    if ( !length $date ) {
        croak
"Method [nextDay] expects an input argument of type Time::Piece.  The given type could not be determined.";
    }

    if ( $date->isa('Time::Piece') ) {
        try {
            $tomorrow = $date + ONE_DAY;
        }
        catch {
            croak "Could not calculate the next day after $date.";
        };
    }
    else {
        croak
          "Method [nextDay] expects an input argument of type Time::Piece.";
    }

    return $tomorrow->date;
}

sub prevDay {
    my ( $class, @params ) = @_;
    my $date = $params[0] // $class;
    my $yesterday = undef;

    if ( !length $date ) {
        croak
"Method [prevDay] expects an input argument of type Time::Piece.  The given type could not be determined.";
    }

    if ( $date->isa('Time::Piece') ) {
        try {
            $yesterday = $date - ONE_DAY;
        }
        catch {
            croak "Could not calculate the next day before $date.";
        };
    }
    else {
        croak
          "Method [prevDay] expects an input argument of type Time::Piece.";
    }

    return $yesterday->date;
}

true;
