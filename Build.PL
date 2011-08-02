use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name         => 'Pod::Tidy',
    dist_version_from   => 'lib/Pod/Tidy.pm',
    author              => 'Joshua Hoblitt <jhoblitt@cpan.org>',
    license             => [ 'perl_5' ],
    create_license      => 1,
    create_makefile_pl  => 'passthrough',
    runtime             => {
        requires            => {
            'File::Copy'            => 0,
            'IO::String'            => 0,
            'Pod::Find'             => 0,
            'Pod::Simple'           => 0,
            'Pod::Wrap'             => 0,
            'Text::Glob'            => '0.06',
            'Text::Wrap'            => 0,
        },
    },
    build               => {
        requires      => {
            'Encode'                => 0,
            'Encode::Newlines'      => '0.03',
            'Test::Cmd'             => '1.05',
        },
        recommends          => {
            'Test::Distribution'    => '1.22',
        },
    },
    script_files        => [qw(
        scripts/podtidy
    )],
    meta_merge     => {
        'meta-spec' => {
          version => '2',
          url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
        },
        release_status      => 'stable',
        resources => {
            license     => [ 'http://dev.perl.org/licenses/' ],
            bugtracker  => {
                web         => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Pod-Tidy',
                mailto      => 'datetime@perl.org',
            },
            repository  => {
                url         => 'git://github.com/jhoblitt/Pod-Tidy.git',
                web         => 'https://github.com/jhoblitt/Pod-Tidy/',
                type        => 'git',
            },
        },
    },
)->create_build_script;
