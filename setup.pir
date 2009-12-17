#!/usr/bin/env parrot
# Copyright (C) 2009, Jonathan "Duke" Leto

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

    .const 'Sub' test = 'test'
    register_step('test', test)

    $P0 = new 'Hash'
    $P0['name'] = 'tapir'
    $P0['abstract'] = 'Fast TAP Harness written in PIR'
    $P0['authority'] = 'http://github.com/leto'
    $P0['description'] = 'Fast TAP Harness written in PIR'
    $P1 = split ';', 'TAP;harness;testing'
    $P0['keywords'] = $P1
    $P0['license_type'] = 'Artistic License 2.0'
    $P0['license_uri'] = 'http://www.perlfoundation.org/artistic_license_2_0'
    $P0['copyright_holder'] = "Jonathan \"Duke\" Leto"
    $P0['checkout_uri'] = 'git://github.com/leto/tapir.git'
    $P0['browser_uri'] = 'http://github.com/leto/tapir'
    $P0['project_uri'] = 'http://github.com/leto/tapir'

    # build
    $P2 = new 'Hash'
    $P2['t/harness.pbc'] = 't/harness.pir'
    $P2['lib/Tapir/Parser.pbc'] = 'lib/Tapir/Parser.pir'
    $P2['lib/Tapir/Stream.pbc'] = 'lib/Tapir/Stream.pir'
    $P0['pbc_pir'] = $P2

    $P3 = new 'Hash'
    $P4 = split ' ', 't/harness.pbc lib/Tapir/Parser.pbc lib/Tapir/Stream.pbc'
    $P3['tapir.pbc'] = $P4
    $P0['pbc_pbc'] = $P3

    $P5 = new 'Hash'
    $P5['parrot-tapir'] = 'tapir.pbc'
    $P0['exe_pbc'] = $P5
    $P0['installable_pbc'] = $P5

    .tailcall setup(args :flat, $P0 :flat :named)
.end

.sub 'test' :anon
    .param pmc kv :slurpy :named
    run_step('build', kv :flat :named)

    .local pmc config
    config = get_config()
    $S0 = config['osname']
    .local string cmd
    unless $S0 == 'MSWin32' goto L1
    cmd = 'tapir.exe'
    goto L2
  L1:
    cmd = './tapir'
  L2:
    cmd .= ' t/*.t'
    system(cmd, 1 :named('verbose'))
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
