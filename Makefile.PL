use inc::Module::Install;

name     'Net-API-RPX';
all_from 'lib/Net/API/RPX.pm';
author   'Scott McWhirter <konobi@cpan.org>';

build_requires 'Test::More';
build_requires 'Test::Exception';
build_requires 'mocked';

requires 'JSON::Any';
requires 'LWP::UserAgent';
requires 'Moose' => '0.70';
requires 'URI';

license 'bsd';

auto_install;

WriteAll;

