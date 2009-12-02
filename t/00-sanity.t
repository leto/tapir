#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(2)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    $S0   = typeof klass
    is($S0,"Class","Class of Tapir::Parser is of the correct type")

    tapir = klass.'new'()
    isa_ok(tapir,klass,"new returns a Tapir::Parser object")

.end

