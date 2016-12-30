package LectServe;

use v5.22;
use Dancer2;
use Dancer2::Plugin::Cache::CHI;

use Time::Piece;
use Date::Lectionary;
use Date::Lectionary::Time qw(nextSunday);

our $VERSION = '1.20161230';

check_page_cache;

get '/' => sub {
    cache_page send_as html => template 'index.tt';
};

get '/date/:day' => sub {
    my $day = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    cache_page send_as JSON =>
      getLectionary( $date, query_parameters->get('lect') );
};

get '/today' => sub {
    my $today = localtime;

    cache_page send_as JSON =>
      getLectionary( $today, query_parameters->get('lect') );
};

get '/sunday' => sub {
    my $today      = localtime;
    my $nextSunday = nextSunday($today);

    cache_page send_as JSON =>
      getLectionary( $nextSunday, query_parameters->get('lect') );
};

get '/html/today' => sub {
    my $today = localtime;
    my $lectHash = getLectionary( $today, query_parameters->get('lect') );

    cache_page send_as html => template 'readings.tt', $lectHash;
};

get '/html/sunday' => sub {
    my $today      = localtime;
    my $nextSunday = nextSunday($today);
    my $lectHash = getLectionary( $nextSunday, query_parameters->get('lect') );

    cache_page send_as html => template 'readings.tt', $lectHash;
};

get '/html/date/:day' => sub {
    my $day      = route_parameters->get('day');
    my $date     = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectHash = getLectionary( $date, query_parameters->get('lect') );

    cache_page send_as html => template 'readings.tt', $lectHash;
};

get '/html/about' => sub {
    cache_page send_as html => template 'about.tt';
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

true;
