use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name         => 'Pod::Tidy',
    dist_version_from   => 'lib/Pod/Tidy.pm',
    author              => 'Joshua Hoblitt <jhoblitt@cpan.org>',
    license             => 'gpl',
    create_makefile_pl  => 'passthrough',
    requires            => {
        'File::Copy'    => '0',
        'IO::String'    => '0',
        'Pod::Find'     => '0',
        'Pod::Simple'   => '0',
        'Pod::Wrap'     => '0',
        'Text::Wrap'    => '0',
    },
    build_requires      => {
        'Test::Cmd'     => 0,
        'Test::Pod'     => '0.95',
    },
    script_files        => [qw(
        scripts/podtidy
    )],
)->create_build_script;
