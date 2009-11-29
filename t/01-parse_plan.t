#!parrot

#   .include 'lib/Tapir/Base.pir'
#    load_bytecode 'PGE.pbc'
#    load_bytecode 'Dumper.pbc'
.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'


.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(9)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_parse_plan(tapir)
    test_parse_tapstream_simple(tapir)
.end

.sub test_parse_tapstream_simple
    .param pmc tapir
    .local pmc stream
    $S0  = "1..2\nok 1\nnot ok 2\n"
    stream = tapir.'parse_tapstream'($S0)
    $S1 = typeof stream
    is($S1,"Tapir;Stream","parse_tapstream returns a Tapir;Stream object")

    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,1,"parse_tapstream detects a passing test")

    $I0 = stream.'get_fail'()
    is($I0,1,"parse_tapstream detects a failing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")
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

