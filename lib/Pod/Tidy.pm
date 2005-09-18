# Copyright (C) 2005  Joshua Hoblitt
#
# $Id$

package Pod::Tidy;

use strict;
use warnings FATAL => qw( all );

use vars qw( $VERSION );
$VERSION = '0.01';

use Fcntl ':flock';
use IO::String;
use Pod::Find qw( contains_pod );
use Pod::Simple;
use Pod::Wrap::Pretty;

sub tidy_files
{
    my %p = @_;

    my $queue = build_pod_queue(
        files       => $p{files},
        recursive   => $p{recursive},
        verbose     => $p{verbose},
    );
    process_pod_queue(
        inplace     => $p{inplace},
        nobackup    => $p{nobackup},
        queue       => $p{queue},
    ); 
}

sub tidy_filehandle
{
    my $input = shift;

    my $wrapper = Pod::Wrap::Pretty->new;
    $wrapper->parse_from_filehandle($input);
}

sub process_pod_queue 
{
    my %p = @_;

    my $verbose     = $p{verbose};
    my $inplace     = $p{inplace};
    my $queue       = $p{queue};
    my $nobackup    = $p{nobackup};

    # count the number of files processed
    my $processed = 0;
    my $wrapper = Pod::Wrap::Pretty->new;

    foreach my $filename (@{ $queue }) {
        # all files in queue should have already been checked to be readable
        open(my $src, '+<', $filename) or warn "can't open file: $!" && next;

        # wait for an execlusive lock incase we want to modify the file
        flock($src, LOCK_EX);

        # slurp the file into memory to avoid making a tmp file
        my $doc = do { local $/; <$src> };

        # create a filehandle
        my $input = IO::String->new($doc);

        # modify in place?
        if ($inplace) {
            my $output = IO::String->new;
            $wrapper->parse_from_filehandle($input, $output);

            # leave the mtime alone if we didn't change anything
            next if ${$input->string_ref} eq ${$output->string_ref};

            # backup existing file
            unless ($nobackup) { }

            # overwrite the original file
            truncate($src, 0);
            seek($src, 0, 0);
            print $src ${$output->string_ref};
        } else {
            $wrapper->parse_from_filehandle($input);
        }

        $processed++;
    }

    return $processed;
}

sub build_pod_queue
{
    my %p = @_;

    # deref once
    my $verbose     = $p{verbose};
    my $recursive   = $p{recursive};

    my @queue;
    foreach my $item (@{ $p{files} }) {
        # FIXME do we need to add symlink handling options?

        # is it a file?
        if (-f $item) {
            # only check if we can read the file, we don't need to be able to
            # write to it unless we're doing an inplace edit
            unless (-r $item) {
                warn "$0: omitting file \`$item\': permission denied\n";
                next;
            }

            unless (contains_pod($item, 0)) {
                warn "$0: omitting file \`$item\': does not contain Pod\n"
                    if $verbose;
                next;
            }

            unless (valid_pod_syntax($item, $verbose)) {
                warn "$0: omitting file \`$item\': bad Pod syntax\n"
                    if $verbose;
                next;
            }

            push @queue, $item;

            next;
        } 

        # is it a dir?
        if (-d $item) {
            unless (-r $item and -x $item) {
                warn "$0: omitting file \`$item\': permission denied\n";
                next;
            }

            # is recursion allowed?
            if ($recursive) {
                opendir(my $dir, $item) or warn "can't open dir: $!" && next;
                my @files = grep !/^\.{1,2}$/, readdir($dir);
                @files = map { "$item/$_" } @files;
                push(@queue, @{ build_pod_queue(
                    files       => \@files,
                    verbose     => $verbose,
                    recursive   => $recursive
                ) });
#                my %pods = pod_find({ -verbose => $verbose, -inc => 0 }, $item);
#                push @queue, keys %pods;
            } else {
                # ignoring $item, recursion not enabled
            warn "$0: omitting direcotry \`$item\': recursion is not enabled\n" 
                if $verbose;
            }
            next;
        }

        # it must be bogus
        warn "$0: \`$item\': no such file or directory\n" if $verbose;
    }

    return \@queue;
}

sub valid_pod_syntax
{
    my ($file, $verbose) = @_;

    # method for checking syntax stolen from Test::Pod
    my $parser = Pod::Simple->new;

    $parser->complain_stderr(1) if $verbose;
    $parser->parse_file($file);

    return $parser->any_errata_seen ? undef : 1;
}

1;

__END__