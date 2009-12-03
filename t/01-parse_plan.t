#!/usr/bin/env parrot

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .include 'test_more.pir'
    .local pmc tapir, klass

    plan(11)

    # setup test data
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    # run tests
    test_parse_plan(tapir)
    test_parse_invalid_plan(tapir)
.end


.sub test_parse_plan
    .param pmc tapir
    .local int num_tests

    num_tests = tapir.'parse_plan'("1..5")
    is(num_tests,5,'parse_plan can parse a simple plan')

    num_tests = tapir.'parse_plan'("1..1")
    is(num_tests,1,'parse_plan can parse a single test plan')

    num_tests = tapir.'parse_plan'("1..0")
    is(num_tests,0,'parse_plan can parse a no-test plan')

.end

.sub test_parse_invalid_plan
    .param pmc tapir
    .local int num_tests

    # these are not valid and should cause an "invalid plan" error
    num_tests = tapir.'parse_plan'("-42..0")
    is(num_tests,-1,'parse_plan indicates an invalid plan for -42..0')

    num_tests = tapir.'parse_plan'("-42..42")
    is(num_tests,-1,'parse_plan indicates an invalid plan for -42..42')

    num_tests = tapir.'parse_plan'("0..1")
    is(num_tests,-1,'parse_plan indicates an invalid plan for 0..1')

    num_tests = tapir.'parse_plan'("1...69")
    is(num_tests,-1,'parse_plan indicates an invalid plan for 1...69')

    num_tests = tapir.'parse_plan'("1..")
    is(num_tests,-1,'parse_plan indicates an invalid plan for 1..')

    num_tests = tapir.'parse_plan'("1.2..69")
    is(num_tests,-1,'parse_plan indicates an invalid plan for 1.2..69')

    num_tests = tapir.'parse_plan'("This is not even close to a valid plan!")
    is(num_tests,-1,'parse_plan indicates an invalid plan for junk')

    num_tests = tapir.'parse_plan'("....2")
    is(num_tests,-1,'parse_plan indicates an invalid plan for ....2')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

