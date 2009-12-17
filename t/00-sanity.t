#!/usr/bin/env parrot


.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass
    load_bytecode 'lib/Tapir/Parser.pbc'
    load_bytecode 'lib/Tapir/Stream.pbc'

    plan(2)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    $S0   = typeof klass
    is($S0,"Class","Class of Tapir::Parser is of the correct type")

    tapir = klass.'new'()
    isa_ok(tapir,klass,"new returns a Tapir::Parser object")

.end

