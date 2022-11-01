#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Dancer2;
use LectServe;
use Plack::Builder;

builder {
	enable 'Deflater';
	dance;
}
