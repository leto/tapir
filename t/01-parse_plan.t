#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(3)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_parse_plan(tapir)
.end


.sub test_parse_plan
    .param pmc tapir
    .local int num_tests

    $S0  = "1..5\nCauchy Residue Theorem!"
    num_tests = tapir.'parse_plan'($S0)
    is(num_tests,5,'parse_plan can parse a simple plan')

    $S0  = "1..1\nCauchy Residue Theorem!"
    num_tests = tapir.'parse_plan'($S0)
    is(num_tests,1,'parse_plan can parse a single test plan')

    $S0  = "1..0\nCauchy Residue Theorem!"
    num_tests = tapir.'parse_plan'($S0)
    is(num_tests,0,'parse_plan can parse a no-test plan')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

