#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

use strict;
use warnings FATAL => qw( all );

use lib qw( ./lib ./t );

use Test::More tests => 5;

use File::Temp qw( tempdir );
use Pod::Tidy;
use Test::Pod::Tidy;

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $VALID_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $queue = Pod::Tidy::build_pod_queue(
        files => [$tmp_valid->filename, $tmp_invalid->filename],
    );

    is_deeply($queue, [$tmp_valid->filename], "plain file list");
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $VALID_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $queue = Pod::Tidy::build_pod_queue(
        files => [$dir],
    );

    # recusion is disabled by default
    is($queue, undef, "dir witht recursive disabled");
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $VALID_POD;
    print $tmp_invalid $INVALID_POD;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my $queue = Pod::Tidy::build_pod_queue(
        files       => [$dir],
        recursive   => 1,
    );

    is_deeply($queue, [$tmp_valid->filename], "dir with recursive enabled");
}

{
    my $queue = Pod::Tidy::build_pod_queue();

    is($queue, undef, "no params");
}

{
    my $queue = Pod::Tidy::build_pod_queue(
        files => undef,
    );

    is($queue, undef, "files param is undef");
}
