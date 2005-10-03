#!/usr/bin/env perl

# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

use strict;
use warnings;

use lib qw( ./lib );

use File::Temp qw( tempdir );
use Pod::Tidy;
use Test::Cmd;
use Test::More tests => 29;

my $before =<<END;
=head1 NAME

perlpodspec - Plain Old Documentation: format specification and notes

=head1 DESCRIPTION

This document is detailed notes on the Pod markup language.  Most
people will only have to read L<perlpod|perlpod> to know how to write
in Pod, but this document may answer some incidental questions to do
with parsing and rendering Pod.

In this document, "must" / "must not", "should" /
"should not", and "may" have their conventional (cf. RFC 2119)
meanings: "X must do Y" means that if X doesn't do Y, it's against
this specification, and should really be fixed.  "X should do Y"
means that it's recommended, but X may fail to do Y, if there's a
good reason.  "X may do Y" is merely a note that X can do Y at
will (although it is up to the reader to detect any connotation of
"and I think it would be I<nice> if X did Y" versus "it wouldn't
really I<bother> me if X did Y").

Notably, when I say "the parser should do Y", the
parser may fail to do Y, if the calling application explicitly
requests that the parser I<not> do Y.  I often phrase this as
"the parser should, by default, do Y."  This doesn't I<require>
the parser to provide an option for turning off whatever
feature Y is (like expanding tabs in verbatim paragraphs), although
it implicates that such an option I<may> be provided.

=cut
END

my $after =<<END;
=head1 NAME

perlpodspec - Plain Old Documentation: format specification and notes

=head1 DESCRIPTION

This document is detailed notes on the Pod markup language.  Most people will
only have to read L<perlpod|perlpod> to know how to write in Pod, but this
document may answer some incidental questions to do with parsing and rendering
Pod.

In this document, "must" / "must not", "should" / "should not", and "may" have
their conventional (cf. RFC 2119) meanings: "X must do Y" means that if X
doesn't do Y, it's against this specification, and should really be fixed.  "X
should do Y" means that it's recommended, but X may fail to do Y, if there's a
good reason.  "X may do Y" is merely a note that X can do Y at will (although
it is up to the reader to detect any connotation of "and I think it would be
I<nice> if X did Y" versus "it wouldn't really I<bother> me if X did Y").

Notably, when I say "the parser should do Y", the parser may fail to do Y, if
the calling application explicitly requests that the parser I<not> do Y.  I
often phrase this as "the parser should, by default, do Y."  This doesn't
I<require> the parser to provide an option for turning off whatever feature Y
is (like expanding tabs in verbatim paragraphs), although it implicates that
such an option I<may> be provided.

=cut
END

my $invalid_pod =<<END;
=pod

=end

=begin

=bogustag

=back
END

my $cmd = Test::Cmd->new(prog => 'scripts/podtidy', workdir => '');
isa_ok($cmd, 'Test::Cmd');

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $before;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    my @files = ( $tmp_valid->filename, $tmp_invalid->filename);

    $cmd->run(args => join " ", @files);

    cmd_output($cmd, 0, $after, '^$');
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $before;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    $cmd->run(args => "$dir");

    # recusion is disabled by default
    cmd_output($cmd, 0, '^$', '^$');
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $before;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    $cmd->run(args => "-r $dir");

    cmd_output($cmd, 0, $after, '^$');
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $before;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    $cmd->run(args => "-ri $dir");

    seek $tmp_valid, 0, 0;
    my $output = do { local $/; <$tmp_valid> };
    
    cmd_output($cmd, 0, '^$', '^$');
    ok(-e $tmp_valid->filename . $Pod::Tidy::BACKUP_POSTFIX,
        "created backup file");
    is($output, $after, "file reformatted in place");
}

{
    my $dir = tempdir( CLEANUP => 1 );
    my $tmp_valid   = File::Temp->new( DIR => $dir );
    my $tmp_invalid = File::Temp->new( DIR => $dir );

    print $tmp_valid $before;
    print $tmp_invalid $invalid_pod;
    $tmp_valid->flush;
    $tmp_invalid->flush;

    $cmd->run(args => "-rin $dir");

    seek $tmp_valid, 0, 0;
    my $output = do { local $/; <$tmp_valid> };

    ok(!-e $tmp_valid->filename . $Pod::Tidy::BACKUP_POSTFIX,
        "created backup file");
    cmd_output($cmd, 0, '^$', '^$');
    is($output, $after, "file reformatted in place");
}

# XXX -h is broken
$cmd->run(args => '--h');
cmd_output($cmd, 0, "Usage", '^$');

$cmd->run(args => '-?');
cmd_output($cmd, 0, "Usage", '^$');

$cmd->run(args => '--help');
cmd_output($cmd, 0, "Usage", '^$');

sub cmd_output
{
    my ($cmd, $exit, $stdout, $stderr) = @_;

    is($? >> 8, $exit, "error code is: $exit");
    like($cmd->stdout, qr/$stdout/, "stdout string");
    like($cmd->stderr, qr/$stderr/, "stderr string");
}
