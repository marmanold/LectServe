package LectServe::Helpers;

use v5.22;
use strict;
use warnings;

use Carp;
use Try::Catch;
use Text::Trim;

use Time::Piece;
use Time::Seconds;
use Date::Lectionary;
use Date::Lectionary::Time qw(nextSunday prevSunday);
use Date::Lectionary::Daily;

use Exporter 'import';
our @EXPORT_OK =
  qw(getAllLectionary getDailyLectionary getSundayLectionary parseCitation cleanToday nextDay prevDay prevMonth nextMonth);

our $VERSION = '1.20210127';

sub parseCitation {
    my $rawCitation = shift;
    my $parsedCitation = $rawCitation;
    $parsedCitation =~ s/(\(|\))//g;
    $parsedCitation =~ s/ or /;/g;

    my @parsedArr   = $parsedCitation =~ m/^\d?\s?[a-z ]{3,20}/gi;
    my $parsedBook  = $parsedArr[0];
    my @citationArr = split( ';', $parsedCitation );

    my @cleanCitationArr;
    my $ct = 0;
    foreach my $citation (@citationArr) {
        $citation =~ s/\d?\s?[a-z ]{3,20}//gi;
        push( @cleanCitationArr, trim($parsedBook) . ' ' . trim($citation) );
        $ct++;
    }

    return join( ',', @cleanCitationArr );
}

#Helper Methods used in resolving routes
sub getAllLectionary {
    my $day       = shift;
    my $lect      = shift;
    my $dailyLect = shift;

    my $nextSunday = undef;

    if ( $day->day_of_week == 0 ) {
        $nextSunday = $day;
    }
    else {
        $nextSunday = nextSunday($day);
    }

    return {
        sunday     => getSundayLectionary( $nextSunday, $lect ),
        daily      => getDailyLectionary( $day, $dailyLect ),
        red_letter => getSundayLectionary( $day, $lect )
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
        date        => $day->date,
        day         => $day->fullday,
        date_pretty => $day->day_of_month . '. '
          . $day->fullmonth . ' '
          . $day->year,
        lectionary => $lectionary->lectionary,
        year       => $lectionary->year->name,
        services   => [@services],
        nextSunday => nextSunday($day)->date,
        prevSunday => prevSunday($day)->date,
        type       => $lectionary->day->type,
    };
}

sub getDailyLectionary {
    my $day       = shift;
    my $dailyLect = shift;

    my $lectionary;
    if ($dailyLect) {
        $lectionary = Date::Lectionary::Daily->new(
            'date'       => $day,
            'lectionary' => $dailyLect
        );
    }
    else {
        $lectionary = Date::Lectionary::Daily->new( 'date' => $day );
    }

    my $readings = {
        morning => {
            first  => $lectionary->readings->{morning}->{1},
            second => $lectionary->readings->{morning}->{2},
        },
        evening => {
            first  => $lectionary->readings->{evening}->{1},
            second => $lectionary->readings->{evening}->{2},
        }
    };

    return {
        date        => $day->date,
        day         => $day->fullday,
        date_pretty => $day->day_of_month . '. '
          . $day->fullmonth . ' '
          . $day->year,
        lectionary => $lectionary->lectionary,
        week       => $lectionary->week,
        readings   => $readings,
        tomorrow   => nextDay($day),
        yesterday  => prevDay($day)
    };
}

sub cleanToday {
    my $localTime = localtime;
    my $today     = $localTime->ymd;
    return Time::Piece->strptime( "$today", "%Y-%m-%d" );
}

sub nextDay {
    my ( $class, @params ) = @_;
    my $date     = $params[0] // $class;
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
        croak "Method [nextDay] expects an input argument of type Time::Piece.";
    }

    return $tomorrow->date;
}

sub prevDay {
    my ( $class, @params ) = @_;
    my $date      = $params[0] // $class;
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
        croak "Method [prevDay] expects an input argument of type Time::Piece.";
    }

    return $yesterday->date;
}

sub nextMonth {
    my $month = shift;
    my $year = shift;

    if ($month == 12) {
        return {"month"=>1, "year"=>$year+1};
    }

    return {"month"=>$month + 1, "year"=>$year};
}

sub prevMonth {
    my $month = shift;
    my $year = shift;

    if ($month == 1) {
        return {"month"=>12, "year"=>$year-1};
    }

    return {"month"=>$month - 1, "year"=>$year};
}

1;
