package LectServe::Calendar;

use v5.22;
use strict;
use warnings;

use FindBin;
use File::Spec;
use lib File::Spec->catdir( $FindBin::Bin, '..', '..', 'lib' );

use Time::Piece;
use Calendar::Simple;
use LectServe::Helpers qw(getSundayLectionary);

use Exporter 'import';
our @EXPORT_OK = qw(getCalendar);

our $VERSION = '1.20201229';

sub getCalendar {
    my $month = shift;
    my $year  = shift;

    my @lectCal = ();
    foreach my $row ( calendar( $month, $year, 0 ) ) {
        my @lectRow = ();
        foreach my $col (@$row) {
            if ( defined($col) ) {
                push(
                    @lectRow,
                    {
                        "day"        => $col,
                        "lectionary" => getSundayLectionary(
                            Time::Piece->strptime(
                                "$year-$month-$col", "%Y-%m-%d"
                            )
                        )
                    }
                );
            }
            else {
                push( @lectRow, { "day" => $col, "lectionary" => undef } );
            }
        }
        push( @lectCal, \@lectRow );
    }

    return \@lectCal;
}

1;
