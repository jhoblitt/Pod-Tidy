#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt

use strict;
use warnings FATAL => qw( all );

use lib qw( ./lib ./t );

use Test::More tests => 3;

use File::Temp qw( tempdir );
use IO::String;
use Pod::Tidy;
use Test::Pod::Tidy;

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid = File::Temp->new( DIR => $dir );

    print $tmp_valid $MESSY_POD;
    $tmp_valid->flush;
    seek $tmp_valid, 0, 0;

    my $output;
    tie *STDOUT, 'IO::String', \$output;

    my $status = Pod::Tidy::tidy_filehandle($tmp_valid);

    is($status, 1, "true return status");
    is($output, $TIDY_POD, "reformatted file sent to STDOUT");
}

{
    my $status = Pod::Tidy::tidy_filehandle();

    is($status, undef, "no params");
}
