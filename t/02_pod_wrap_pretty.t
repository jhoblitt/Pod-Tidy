#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

use strict;
use warnings FATAL => qw( all );

use lib qw( ./lib ./t );

use Test::More tests => 2;

use IO::String;
use Pod::Wrap::Pretty;
use Test::Pod::Tidy;

{
    my $input = IO::String->new($MESSY_POD);
    my $output = IO::String->new;

    my $w = Pod::Wrap::Pretty->new;

    $w->parse_from_filehandle($input, $output);

    is(${$output->string_ref}, $TIDY_POD, "test line-breaking");
}

my $POD_WS_TAIL =<<END;
=head2 C source tests

C source tests are usually located in F<t/src/*.t>.  A simple test looks like:  

    c_output_is(<<'CODE', <<'OUTPUT', "name for test");
    #include <stdio.h>
    #include "parrot/parrot.h"
    #include "parrot/embed.h"

=cut
END

my $POD_WS_TRIMMED =<<END;
=head2 C source tests

C source tests are usually located in F<t/src/*.t>.  A simple test looks like:

    c_output_is(<<'CODE', <<'OUTPUT', "name for test");
    #include <stdio.h>
    #include "parrot/parrot.h"
    #include "parrot/embed.h"

=cut
END

{
    my $input = IO::String->new($POD_WS_TAIL);
    my $output = IO::String->new;

    my $w = Pod::Wrap::Pretty->new;

    $w->parse_from_filehandle($input, $output);

    is(${$output->string_ref}, $POD_WS_TRIMMED, "test ws tail trimming");
}
