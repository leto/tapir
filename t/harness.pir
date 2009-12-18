# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>


.sub version
    say "Tapir version 0.01"
    exit 0
.end

.sub help
    say <<"HELP"

Tapir is a TAP test harness. There are different ways to run it, depending on
your preferences and build, but this should always work:

        parrot t/harness.pir t/*.t

If you have created binary "fakecutable" (this requires a working compiler in
your PATH) then you can use Tapir like this:

        ./tapir t/*.t

Currently supported arguments:
    --exec=program      Use a given program to execute test scripts
                        i.e. ./tapir --exec=perl t/*.t to run Perl tests
    --help              This message

HELP
    exit 0
.end

.sub _parse_opts
    .param pmc argv
    .local pmc getopts, opts
    load_bytecode "Getopt/Obj.pbc"
    getopts = new 'Getopt::Obj'
    getopts."notOptStop"(1)
    push getopts, "exec|e:s"
    push getopts, "version"
    push getopts, "help"
    opts = getopts."get_options"(argv)
    .return(opts)
.end

.sub _find_max_file_length
    .param pmc files
    .local int numfiles
    .local int maxlength
    numfiles = files
    maxlength = 0
    $I0 = -1
  loop_top:
    inc $I0
    if $I0 > numfiles goto loop_bottom
    $S0 = files[$I0]
    $I1 = length $S0
    if $I1 <= maxlength goto loop_top
    maxlength = $I1
    goto loop_top
  loop_bottom:
    .return(maxlength)
.end

.sub _print_elipses
    .param string filename
    .param int maxlength
    .local int namelength
    .local int lengthdiff
    namelength = length filename
    lengthdiff = maxlength - namelength
    $I0 = lengthdiff + 2
    $S0 = repeat ".", $I0
    print " "
    print $S0
    print " "
.end

.sub main :main
    .param pmc argv
    .local pmc opts
    .local string exec
    .local int argc
    .local num start_time, end_time

    start_time  = time
    $S0  = shift argv  # get rid of harness.pir in the args list

    argc = elements argv
    if argc > 0 goto load_libs
    help()

  load_libs:
    load_bytecode 'lib/Tapir/Parser.pbc'
    load_bytecode 'lib/Tapir/Stream.pbc'


    # parse command line args
    opts = _parse_opts(argv)
    exec = opts["exec"]
    $S1  = opts["version"]
    $S2  = opts["help"]

    unless $S2 goto check_version
    help()

  check_version:
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
    .local int namelength

    namelength = _find_max_file_length(argv)
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
    _print_elipses(file, namelength)

    # we assume the test is PIR unless given an --exec flag
    # how to do proper shebang-line detection?
    .local string exec_cmd
    exec_cmd = 'parrot'
    unless exec goto run_cmd
    exec_cmd = exec
  run_cmd:
    qx_data   = qx(exec_cmd,file)
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
    unless $I1 goto newline
    print ", exit code = "
    say $I1
    goto redo
 newline:
    print "\n"
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
    end_time = time
    $N1 = end_time - start_time
    print "Runtime: "
    $P0 = new 'ResizablePMCArray'
    $P0[0] = $N1
    $S1 = sprintf "%.4f", $P0
    print $S1
    say " seconds"
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

