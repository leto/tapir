#!parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(33)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_parse_plan(tapir)
    test_is_pass(tapir)
    test_parse_tapstream_simple(tapir)
    test_parse_tapstream_all_pass(tapir)
    test_parse_tapstream_all_fail(tapir)
    test_parse_tapstream_diagnostics(tapir)
.end

.sub test_is_pass
    .param pmc tapir
    .local pmc stream
    $S0  = "1..2\nok 1 - i like cheese\nok 2 - foobar\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'is_pass'()
    is($I0,1,"is_pass correctly detects 2 passing tests")

    $S0  = "1..3\nok 1 - i like cheese\nok 2 - foobar\nnot ok 3 - blammo!\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'is_pass'()
    is($I0,0,"is_pass correctly detected 1 failing test")

    $S0  = "1..2\nok 1 - i like cheese\nok 2 - foobar\nok 3 - blammo!\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'is_pass'()
    is($I0,0,"is_pass correctly detects that too many tests have run")

    $S0  = "1..4\nok 1 - i like cheese\nok 2 - foobar\nok 3 - blammo!\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'is_pass'()
    is($I0,0,"is_pass correctly detects that too few tests have run")
.end

.sub test_parse_tapstream_diagnostics
    .param pmc tapir
    .local pmc stream
    $S0  = "1..2\nok 1 - i like cheese\nok 2 - foobar\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,2,"parse_tapstream detects a passing test with diag")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects no failing test")

    $S0  = "1..2\nnot ok 1 - i like cheese\nnot ok 2 - foobar\n"
    stream = tapir.'parse_tapstream'($S0)
    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,0,"parse_tapstream detects no passing tests with diag")

    $I0 = stream.'get_fail'()
    is($I0,2,"parse_tapstream detects 2 failing tests with diag")

    $I0 = stream.'total'()
    is($I0,2,"parse_tapstream detected 2 tests in total")
.end

.sub test_parse_tapstream_all_pass
    .param pmc tapir
    .local pmc stream
    $S0  = "1..2\nok 1\nok 2\n"
    stream = tapir.'parse_tapstream'($S0)

    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,2,"parse_tapstream detects a passing test")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects a failing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")

    $I0 = stream.'total'()
    is($I0,2,"parse_tapstream detected 2 tests in total")
.end

.sub test_parse_tapstream_all_fail
    .param pmc tapir
    .local pmc stream
    $S0  = "1..2\nnot ok 1\nnot ok 2\n"
    stream = tapir.'parse_tapstream'($S0)

    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,0,"parse_tapstream detects no passing tests")

    $I0 = stream.'get_fail'()
    is($I0,2,"parse_tapstream detects 2 failing tests")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")

    $I0 = stream.'total'()
    is($I0,2,"parse_tapstream detected 2 tests in total")
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

    $I0 = stream.'total'()
    is($I0,2,"parse_tapstream detected 2 tests in total")
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

