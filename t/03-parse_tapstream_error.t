#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(19)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    test_parse_death(tapir)
    test_parse_death_with_passing_tests(tapir)
    test_plumage_sanity(tapir)
.end

.sub test_plumage_sanity
    .param pmc tapir
    .local string tap_error
    .local pmc stream
    tap_error = <<"TAP"
1..18
invalidjunkdoesnotexist
ok 1 - do_run()ing invalidjunk returns false
./plumage asdfversion
I don't know how to 'asdfversion'!
ok 2 - plumage returns failure for invalid commands
ok 3
ok 4
ok 5
ok 6
ok 7
ok 8 - no args give usage
ok 9 - no args give usage
ok 10 - plumage fetch no args
ok 11
ok 12
./plumage version
This is Parrot Plumage, version 0.

Copyright (C) 2009, Parrot Foundation.

This code is distributed under the terms of the Artistic License 2.0.
For more details, see the full text of the license in the LICENSE file
included in the Parrot Plumage source tree.
ok 13 - plumage version returns success
ok 14 - plumage version knows its name
ok 15 - version mentions Parrot Foundation
ok 16 - version mentions Artistic License
ok 17 - info rakudo
ok 18 - info rakudo
.end
TAP
    stream = tapir.'parse_tapstream'(tap_error)

    $I0 = stream.'get_plan'()
    is($I0,18,"plan is correct")

    $I0 = stream.'is_pass'()
    is($I0,1,"parse_tapstream passes Plumage's sanity test")

    $I0 = stream.'get_pass'()
    is($I0,18,"parse_tapstream gets 18 tests")

    $I0 = stream.'get_todo'()
    is($I0,0,"parse_tapstream gets no todo tests")

    $I0 = stream.'get_skip'()
    is($I0,0,"parse_tapstream gets no skip tests")

    $I0 = stream.'get_fail'()
    is($I0,0,"parse_tapstream gets no fails")

    $I0 = stream.'total'()
    is($I0,18,"parse_tapstream gets 18 tests in total")
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

