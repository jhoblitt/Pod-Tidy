#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt

use strict;
use warnings FATAL => qw( all );

use lib qw( ./lib ./t );

use Test::More tests => 3;

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

{
    my $input = IO::String->new($POD_WS_TAIL);
    my $output = IO::String->new;

    my $w = Pod::Wrap::Pretty->new;

    $w->parse_from_filehandle($input, $output);

    is(${$output->string_ref}, $POD_WS_TRIMMED, "test ws tail trimming");
}

{
    my $input = IO::String->new($POD_IDENTIFIER_BLOCK);
    my $output = IO::String->new;

    my $w = Pod::Wrap::Pretty->new;

    $w->parse_from_filehandle($input, $output);

    is(${$output->string_ref}, $POD_IDENTIFIER_BLOCK, "test identifier block non-mangling");
}
