#!/usr/bin/env parrot
# Copyright (C) 2009, Jonathan "Duke" Leto

# Thanks to whiteknight++ (because I stole and tweaked this from
# parrot-linear-algebra) and fperrad++, for writing distutils for Parrot

=head1 NAME

setup.pir - Setup, build, test and install Tapir

=head1 DESCRIPTION

No Configure step, no Makefile generated.

See F<runtime/parrot/library/distutils.pir>.

=head1 USAGE

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.sub 'main' :main
    .param pmc args
    $S0 = shift args
    load_bytecode 'distutils.pbc'

    $P0 = new 'Hash'
    $P0['name'] = 'tapir'
    $P0['abstract'] = 'Fast TAP Harness written in PIR'
    $P0['authority'] = 'http://github.com/leto'
    $P0['description'] = 'Fast TAP Harness written in PIR'
    $P1 = split ';', 'TAP;harness;testing'
    $P0['keywords'] = $P1
    $P0['license_type'] = 'Artistic License 2.0'
    $P0['license_uri'] = 'http://www.perlfoundation.org/artistic_license_2_0'
    $P0['copyright_holder'] = 'Jonathan "Duke" Leto'
    $P0['checkout_uri'] = 'git://github.com/leto/tapir.git'
    $P0['browser_uri'] = 'http://github.com/leto/tapir'
    $P0['project_uri'] = 'http://github.com/leto/tapir'

    # build
    $P4 = new 'Hash'
    $P4['t/harness.pbc'] = 't/harness.pir'
    $P4['lib/Tapir/Parser.pbc'] = 'lib/Tapir/Parser.pir'
    $P4['lib/Tapir/Stream.pbc'] = 'lib/Tapir/Stream.pir'
    $P0['pbc_pir'] = $P4

    # test
    $P0['harness_exec'] = './tapir'
    $P0['harness_files'] = 't/*.t'

    # dist
    $P5 = glob('lib/Tapir/*.pir t/*.pir t/*.t')
    $P0['manifest_includes'] = $P5

    .tailcall setup(args :flat, $P0 :flat :named)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
