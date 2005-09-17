#!/usr/bin/env perl

use strict;
use warnings;

use vars qw( %docs $n_docs );

BEGIN {
    eval "use Pod::Find";
    if ($@) {
        print "1..1\nok 1 # skip Pod::Find not installed\n";
        exit;
    }
    %docs = Pod::Find::pod_find(
        { -verbose => 0, -inc => 0 },
        qw( . ) # search path(s)
    );

    $n_docs = scalar keys %docs;
}

use Test::More tests => $n_docs;

eval "use Test::Pod 0.95";
SKIP: {
    skip "Test::Pod 0.95 not installed.", $n_docs if $@;
    Test::Pod::pod_file_ok( $_ ) foreach keys %docs;
}
