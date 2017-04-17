use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME         => 'LectServe',
    AUTHOR       => q{Michael Arnold <michael@rnold.info>},
    VERSION_FROM => 'lib/LectServe.pm',
    ABSTRACT     => 'YOUR APPLICATION ABSTRACT',
    (
        $eumm_version >= 6.3001
        ? ( 'LICENSE' => 'perl' )
        : ()
    ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More' => 1.302078,
        'YAML'       => 1.23,
        'Dancer2'    => 0.205000,
        'Plack' => 1.0043, 
        'Plack::Middleware::Deflater' => 0.12, 
        'Plack::Middleware::CrossOrigin' => 0.012,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'LectServe-*' },
);
