#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

use strict;
use warnings FATAL => qw( all );

use lib qw( ./lib ./t );

use Test::More tests => 8;

use IO::String;
use File::Temp qw( tempdir );
use Pod::Tidy;
use Test::Pod::Tidy;

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $MESSY_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $output;
    tie *STDOUT, 'IO::String', \$output;

    my $status = Pod::Tidy::tidy_files(
        files => [$tmp_valid->filename, $tmp_invalid->filename],
    );

    is($status, 1, "return status");
    is($output, $TIDY_POD, "reformatted file sent to STDOUT");
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $MESSY_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $output;
    tie *STDOUT, 'IO::String', \$output;

    my $status = Pod::Tidy::tidy_files(
        files => [$dir],
    );

    # recusion is disabled by default
    is($status, undef, "return status");
    is($output, "", "dir with recursive disabled");
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $MESSY_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $output;
    tie *STDOUT, 'IO::String', \$output;

    my $status = Pod::Tidy::tidy_files(
        files       => [$dir],
        recursive   => 1,
    );

    is($status, 1, "return status");
    is($output, $TIDY_POD, "reformatted file sent to STDOUT");
}

{
    my $status = Pod::Tidy::tidy_files();

    is($status, undef, "no params");
}

{
    my $status = Pod::Tidy::tidy_files(
        files => undef,
    );

    is($status, undef, "files param is undef");
}
