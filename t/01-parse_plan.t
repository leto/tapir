#!parrot


.sub main :main
    .include 'test_more.pir'
    load_bytecode 'lib/Tapir/Base.pir'
    load_bytecode 'lib/Tapir/Parser.pir'
    load_bytecode 'PGE.pbc'
    load_bytecode 'Dumper.pbc'

    .local pmc tapir, class
    class = newclass [ 'Tapir'; 'Parser' ]
    tapir = class.'new'()

    plan(1)

    .local int num_tests
    $S0  = "1..5\nCauchy Residue Theorem!"
    _dumper(tapir)
    num_tests = tapir.'parse_plan'($S0)
    is(num_tests,5,'parse_plan can parse a simple plan')
.end
