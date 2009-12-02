#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(12)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    test_parse_death(tapir)
    test_parse_death_with_passing_tests(tapir)

.end

.sub test_parse_death
    .param pmc tapir
    .local string tap_error
    .local pmc stream
    tap_error = <<"TAP"
1..2
not ok 1 - newclass Tapir::Parser is of the correct type
# Have: Class
# Want: Tapir;Parser
get_bool() not implemented in class 'Tapir;Parser'
current instr.: 'parrot;Test;More;ok' pc 39 (runtime/parrot/library/Test/More.pir:108)
called from Sub 'parrot;Tapir;Stream;main' pc 505 (t/00-sanity.t:18)
TAP
    stream = tapir.'parse_tapstream'(tap_error)

    $I0 = stream.'is_pass'()
    is($I0,0,"parse_tapstream does not pass a TAP stream with a death message")

    $I0 = stream.'get_pass'()
    is($I0,0,"parse_tapstream gets no passed tests")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream gets 0 todo tests")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream gets 0 skip tests")

    $I0 = stream.'get_fail'()
    is($I0,1,"parse_tapstream gets one failed test")

    $I0 = stream.'total'()
    is($I0,1,"parse_tapstream gets one test in total")

.end

.sub test_parse_death_with_passing_tests
    .param pmc tapir
    .local string tap_error
    .local pmc stream
    tap_error = <<"TAP"
1..2
ok 1 - new returns a Tapir::Parser object isa Tapir;Parser
Class Stream already registered!

current instr.: 'parrot;Tapir;Stream;main' pc 495 (t/00-sanity.t:18)
TAP
    stream = tapir.'parse_tapstream'(tap_error)

    $I0 = stream.'is_pass'()
    is($I0,0,"parse_tapstream does not pass a TAP stream with a death message")

    $I0 = stream.'get_pass'()
    is($I0,1,"parse_tapstream gets 1 passing test")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream gets 0 todo tests")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream gets 0 skip tests")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream gets no failing tests")

    $I0 = stream.'total'()
    is($I0,1,"parse_tapstream gets one test in total")
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

