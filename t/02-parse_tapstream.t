#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(59)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_is_pass(tapir)
    test_really_simple(tapir)
    test_parse_tapstream_simple(tapir)
    test_parse_tapstream_all_pass(tapir)
    test_parse_tapstream_all_fail(tapir)
    test_parse_tapstream_diagnostics(tapir)
    test_parse_tapstream_too_many_passing_tests(tapir)
    test_parse_tapstream_not_enough_tests(tapir)
    test_parse_tapstream_todo(tapir)
    test_parse_tapstream_skip(tapir)
.end

.sub test_parse_tapstream_skip
    .param pmc tapir
    .local pmc stream
    .local string tap
    tap = <<"TAP"
1..3
ok 1 - Testing some stuff
ok 2 # skip some great reason
ok 3 # SKIP another great reason
TAP
    stream = tapir.'parse_tapstream'(tap)

    $I0 = stream.'get_plan'()
    is($I0,3,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,1,"parse_tapstream detects 1 passing test")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects no failing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo tests")

    $I0 = stream.'get_skip'()
    is($I0,2,"parse_tapstream detects two skipped test")

    $I0 = stream.'total'()
    is($I0,3,"parse_tapstream detected 3 tests in total")

    $I0 = stream.'is_pass'()
    is($I0,1,"parse_tapstream will pass a TAP stream with todo tests")
.end


.sub test_parse_tapstream_todo
    .param pmc tapir
    .local pmc stream
    .local string tap
    tap = <<"TAP"
1..3
ok 1 - Class of Tapir::Parser is of the correct type
ok 2 - new returns a Tapir::Parser object isa Tapir;Parser
not ok 3 # TODO make lots of money
TAP
    stream = tapir.'parse_tapstream'(tap)

    $I0 = stream.'get_plan'()
    is($I0,3,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,2,"parse_tapstream detects 2 passing tests")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects no failing test")

    $I0 = stream.'get_todo'()
    is($I0,1,"parse_tapstream detects one todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")

    $I0 = stream.'total'()
    is($I0,3,"parse_tapstream detected 3 tests in total")

    $I0 = stream.'is_pass'()
    is($I0,1,"parse_tapstream will pass a TAP stream with todo tests")

.end

.sub test_parse_tapstream_not_enough_tests
    .param pmc tapir
    .local pmc stream
    .local string tap
    tap = <<"TAP"
1..5
ok 1 - Class of Tapir::Parser is of the correct type
ok 2 - new returns a Tapir::Parser object isa Tapir;Parser
TAP
    stream = tapir.'parse_tapstream'(tap)

    $I0 = stream.'get_plan'()
    is($I0,5,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,2,"parse_tapstream detects 2 passing tests")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects a failing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")

    $I0 = stream.'total'()
    is($I0,2,"parse_tapstream detected 2 tests in total")

    $I0 = stream.'is_pass'()
    is($I0,0,"parse_tapstream does not pass a TAP stream with not enough tests")
.end

.sub test_parse_tapstream_too_many_passing_tests
    .param pmc tapir
    .local pmc stream
    .local string tap
    tap = <<"TAP"
1..2
ok 1 - Class of Tapir::Parser is of the correct type
ok 2 - new returns a Tapir::Parser object isa Tapir;Parser
ok 3
TAP
    stream = tapir.'parse_tapstream'(tap)

    $I0 = stream.'get_plan'()
    is($I0,2,"parse_tapstream detects the plan correctly")

    $I0 = stream.'get_pass'()
    is($I0,3,"parse_tapstream detects a passing test")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream detects a failing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream detects no todo test")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream detects no skipped test")

    $I0 = stream.'total'()
    is($I0,3,"parse_tapstream detected 2 tests in total")

    $I0 = stream.'is_pass'()
    is($I0,0,"parse_tapstream does not pass a TAP stream with too many tests")
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

.sub test_really_simple
    .param pmc tapir
    .local pmc stream
    $S0  = <<"TAP"
1..1
ok 1 - parse_tapstream does not pass a dead test
TAP
    stream = tapir.'parse_tapstream'($S0)
    $I0    = stream.'is_pass'()
    is($I0,1,"a single passed test with diagnostic works")
.end

