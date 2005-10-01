#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

use strict;
use warnings FATAL => qw( all );

use Test::More 'no_plan';

use lib qw( ./lib );

use Pod::Tidy;
use File::Temp qw( tempdir );

my $valid_pod =<<END;
=head1 foo

bar baz.

=cut
END

my $invalid_pod =<<END;
=pod

=end

=begin

=bogustag

=back
END

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $valid_pod;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    ok(Pod::Tidy::valid_pod_syntax($tmp_valid->filename), "check valid pod");
    is(Pod::Tidy::valid_pod_syntax($tmp_invalid->filename), undef, "check invalid pod");

}

is(Pod::Tidy::valid_pod_syntax(undef), undef, "file doesn't exist");

{
    my $dir = tempdir( CLEANUP => 1 );
    is(Pod::Tidy::valid_pod_syntax("$dir/foo"), undef, "file doesn't exist");
}
