# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .param pmc argv
    $S0  = shift argv  # get rid of harness.pir in the args list
    $I0  = argv
    dec $I0

    .local pmc tapir, klass
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    .local pmc stream
    .local int i
    .local string file
    .local string output
    .local int success
    .local int total_files, failing_files, failing_tests, tests
    i = 0
    failing_files = 0
    failing_tests = 0
    total_files   = 0
    tests         = 0
 loop:
    file = argv[i]
    unless file goto done
    inc total_files
    print file
    print ".........."
    output = qx('parrot',file)
    stream = tapir.'parse_tapstream'(output)
    success = stream.'is_pass'()
    unless success goto fail
    print "passed "
    $I0 = stream.'get_pass'()
    print $I0
    tests += $I0
    say " tests"
    goto redo
 fail:
    print "failed "
    $I0 = stream.'get_fail'()
    print $I0
    inc failing_files
    inc failing_tests
    $S1 = stream.'total'()
    $S0 = "/" . $S1
    print $S0
    say " tests"
 redo:
    inc i
    goto loop

 done:
    if failing_files goto print_fail
    print "PASSED "
    print tests
    print " test(s) in "
    print total_files
    say " files"
    goto over
  print_fail:
    print "FAILED "
    print failing_tests
    print " test(s) in "
    print failing_files
    print "/"
    print total_files
    say " files"
  over:
    .return()
.end

.sub 'qx'
    .param pmc command_and_args :slurpy

    .local string cmd
    cmd = join ' ', command_and_args

    .local pmc pipe
    pipe = open cmd, 'rp'
    unless pipe goto pipe_open_error

    .local pmc output
    pipe.'encoding'('utf8')
    output = pipe.'readall'()
    pipe.'close'()

    .local pmc exit_status
    $I0 = pipe.'exit_status'()
    exit_status = box $I0

    find_dynamic_lex $P0, '$!'
    if null $P0 goto skip_exit_status
    store_dynamic_lex '$!', exit_status
  skip_exit_status:

    .return (output)

  pipe_open_error:
    $S0  = 'Unable to execute "'
    $S0 .= cmd
    $S0 .= '"'
    die $S0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

