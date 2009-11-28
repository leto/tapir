#!parrot

#   .include 'lib/Tapir/Base.pir'
#    load_bytecode 'PGE.pbc'
#    load_bytecode 'Dumper.pbc'
.include 'lib/Tapir/Parser.pir'


.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(1)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_basic(tapir)
.end

.sub test_basic
    .param pmc tapir
    .local int num_tests

    $S0  = "1..5\nCauchy Residue Theorem!"
    num_tests = tapir.'parse_plan'($S0)
    is(num_tests,5,'parse_plan can parse a simple plan')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

