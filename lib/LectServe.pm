package LectServe;

use v5.22;

use Dancer2;
use Dancer2::Plugin::HTTP::Caching;

use Carp;
use Try::Catch;
use REST::Client;
use Text::Trim;

use Time::Piece;
use Time::Seconds;
use Date::Lectionary::Time qw(nextSunday prevSunday);

use Module::Version qw(get_version);
use Template::Stash;

use LectServe::Helpers
  qw(getAllLectionary getDailyLectionary getSundayLectionary parseCitation cleanToday nextDay prevDay prevMonth nextMonth);
use LectServe::Calendar qw(getCalendar);

our $VERSION = '1.20210127';

$Template::Stash::SCALAR_OPS->{ parseCitation } = sub {
    return parseCitation(shift);
};

hook before => sub {
    http_cache_max_age 3600;
    http_cache_public;
};

#Root HTML Endpoints
get '/' => sub {
    my $today      = cleanToday();
    my $lectionary = getAllLectionary( $today, 'acna', 'acna-sec' );

    send_as html => template 'index.tt', $lectionary;
};

get '/home/:day' => sub {
    my $day        = route_parameters->get('day');
    my $date       = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary = getAllLectionary( $date, 'acna', 'acna-sec' );

    send_as html => template 'index.tt', $lectionary;
};

#Calendar Endpoints
get '/calendar' => sub {
    my $date = cleanToday();

    send_as
      html => template 'calendar.tt',
      {
        "year"  => $date->year,
        "month" => $date->fullmonth,
        "rows" => getCalendar($date->mon, $date->year),
        "days" => [qw( Sun Mon Tue Wed Thu Fri Sat )], 
        "prevMonth" => prevMonth($date->mon, $date->year), 
        "nextMonth" => nextMonth($date->mon, $date->year)
      };
};

get '/calendar/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as
      html => template 'calendar.tt',
      {
        "year"  => $date->year,
        "month" => $date->fullmonth,
        "rows" => getCalendar($date->mon, $date->year),
        "days" => [qw( Sun Mon Tue Wed Thu Fri Sat )], 
        "prevMonth" => prevMonth($date->mon, $date->year), 
        "nextMonth" => nextMonth($date->mon, $date->year)
      };
};

#App Endpoints
get '/app/v1/daily/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as
      JSON => getDailyLectionary( $date, query_parameters->get('dailyLect') ),
      { content_type => 'application/json; charset=UTF-8' };
};

get '/app/v1/sunday/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as
      JSON => getSundayLectionary( $date, query_parameters->get('lect') ),
      { content_type => 'application/json; charset=UTF-8' };
};

#JSON Endpoints
get '/date/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );

    send_as
      JSON => getAllLectionary(
        $date,
        query_parameters->get('lect'),
        query_parameters->get('dailyLect')
      ),
      { content_type => 'application/json; charset=UTF-8' };
};

get '/today' => sub {
    send_as
      JSON => getAllLectionary(
        cleanToday(),
        query_parameters->get('lect'),
        query_parameters->get('dailyLect')
      ),
      { content_type => 'application/json; charset=UTF-8' };
};

get '/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );

    send_as
      JSON => getSundayLectionary( $nextSunday, query_parameters->get('lect') ),
      { content_type => 'application/json; charset=UTF-8' };
};

post '/reading' => sub {
    my $readings = getReading( body_parameters->get('query') );
    info body_parameters->get('query');

    send_as
      JSON => $readings,
      { content_type => 'application/json; charset=UTF-8' };
};

#Daily Lectionary HTML Endpoints
get '/html/today' => sub {
    my $today = cleanToday();
    my $dailyReadings =
      getDailyLectionary( $today, query_parameters->get('dailyLect') );
    $dailyReadings->{title} = "Daily Readings";

    send_as html => template 'daily_readings.tt', $dailyReadings;
};

get '/html/daily/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary =
      getDailyLectionary( $date, query_parameters->get('dailyLect') );
    $lectionary->{title} = "Daily Readings";

    send_as html => template 'daily_readings.tt', $lectionary;
};

#Sunday Lectionary HTLM Endpoints
get '/html/last_sunday' => sub {
    my $prevSunday = prevSunday( cleanToday() );
    my $lectHash =
      getSundayLectionary( $prevSunday, query_parameters->get('lect') );
    $lectHash->{title} = "Last Sunday Readings";

    send_as html => template 'sunday_readings.tt', $lectHash;
};

get '/html/sunday' => sub {
    my $nextSunday = nextSunday( cleanToday() );
    my $lectHash =
      getSundayLectionary( $nextSunday, query_parameters->get('lect') );
    $lectHash->{title} = "Sunday Readings";

    send_as html => template 'sunday_readings.tt', $lectHash;
};

get '/html/sunday/:day' => sub {
    my $day      = route_parameters->get('day');
    my $date     = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectHash = getSundayLectionary( $date, query_parameters->get('lect') );
    $lectHash->{title} = "Sunday Readings";

    send_as html => template 'sunday_readings.tt', $lectHash;
};

#Daily Prayer HTML Endpoints
get '/html/morning_prayer' => sub {
    my $today = cleanToday();
    my $dailyReadings =
      getDailyLectionary( $today, query_parameters->get('dailyLect') );
    $dailyReadings->{title} = "Morning Prayer";

    send_as html => template 'morning_prayer.tt', $dailyReadings;
};

get '/html/morning_prayer/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary =
      getDailyLectionary( $date, query_parameters->get('dailyLect') );
    $lectionary->{title} = "Morning Prayer";

    send_as html => template 'morning_prayer.tt', $lectionary;
};

get '/html/evening_prayer' => sub {
    my $today = cleanToday();
    my $dailyReadings =
      getDailyLectionary( $today, query_parameters->get('dailyLect') );
    $dailyReadings->{title} = "Evening Prayer";

    send_as html => template 'evening_prayer.tt', $dailyReadings;
};

get '/html/evening_prayer/:day' => sub {
    my $day  = route_parameters->get('day');
    my $date = Time::Piece->strptime( "$day", "%Y-%m-%d" );
    my $lectionary =
      getDailyLectionary( $date, query_parameters->get('dailyLect') );
    $lectionary->{title} = "Evening Prayer";

    send_as html => template 'evening_prayer.tt', $lectionary;
};

#Additional HTML Endpoints
get '/html/about' => sub {
    var daily_version => get_version('Date::Lectionary::Daily');
    var sun_version   => get_version('Date::Lectionary');
    var time_version  => get_version('Date::Lectionary::Time');
    var app_version   => $VERSION;

    send_as
      html => template 'about.tt',
      { title => 'About & Documentation' };
};

get '/api' => sub {
    send_as html => template 'api.tt';
};

#Method to retrieve scripture text from the ESV API
sub getReading {
    my $readingString = shift;

    my $parsedCitation = parseCitation($readingString);

    my $client = REST::Client->new(
        {
            host    => 'https://api.esv.org',
            timeout => 10
        }
    );

    my $response = $client->GET(
        '/v3/passage/html/?q='
          . $parsedCitation
          . '&wrapping-div=true&inline-styles=true&include-passage-references=true&include-chapter-numbers=false&include-verse-number=false&include-footnotes=false&include-footnote-body=false&include-headings=false&include-subheadings=false&include-surrounding-chapters-below=false&include-audio-link=true',
        {
            Accept        => "application/json",
            Authorization => "Token 6b6576cd1f91f7bb79df4824c08891a558e47647"
        }
    );

    return decode_json( $response->responseContent() );
}

1;
