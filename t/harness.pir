# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub version
    say "Tapir version 0.01"
    exit 0
.end

.sub _parse_opts
    .param pmc argv
    .local pmc getopts, opts
    load_bytecode "Getopt/Obj.pbc"
    getopts = new "Getopt::Obj"
    getopts."notOptStop"(1)
    push getopts, "exec|e:s"
    push getopts, "version"
    opts = getopts."get_options"(argv)
    .return(opts)
.end

.sub main :main
    .param pmc argv
    .local pmc opts
    .local string exec

    $S0  = shift argv  # get rid of harness.pir in the args list

    # parse command line args
    opts = _parse_opts(argv)
    exec = opts["exec"]
    $S1  = opts["version"]

    unless $S1 goto make_parser
    version()

  make_parser:
    .local pmc tapir, klass
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    .local pmc stream, qx_data
    .local int i
    .local string file
    .local string output
    .local int success, exit_code
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
    # these should be normalized to make the output format 'pretty'
    print ".........."

    # we assume the test is PIR unless given an --exec flag
    # how to do proper shebang-line detection?
    .local string exec_cmd
    exec_cmd = 'parrot'
    unless exec goto run_cmd
    exec_cmd = exec
 run_cmd:
    qx_data   = qx(exec,file)
    output    = qx_data[0]
    exit_code = qx_data[1]
  parse:
    stream    = tapir.'parse_tapstream'(output, exit_code)
    success   = stream.'is_pass'()
    unless success goto fail
    print "passed "

    $I0 = stream.'total'() # includes todo tests
    print $I0
    tests += $I0
    say " tests"

    unless exit_code goto redo
    # all tests passed but file had non-zero exit code
    inc failing_files

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
    print " tests"
    $I1 = stream.'get_exit_code'()
    unless $I1 goto redo
    print ", exit code = "
    say $I1

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

    # hack
    $P0 = new 'FixedPMCArray'
    $P0 = 2
    $P0[0] = output
    $P0[1] = exit_status
    .return ($P0)

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

