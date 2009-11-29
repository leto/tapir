# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.include 'lib/Tapir/Parser.pir'
.include 'lib/Tapir/Stream.pir'

.sub main :main
    .param pmc argv
    $S0  = shift argv  # get rid of harness.pir in the args list
    say argv
    $I0  = argv
    dec $I0
    say "I will be a PIR TAP harness one day when I am big and strong!"

    .local pmc tapir, klass
    klass = newclass [ 'Tapir'; 'Parser' ]
    tapir = klass.'new'()

    .local pmc stream
    .local int i
    .local string file
    .local string output
    .local int success
    i = 0
 loop:
    if i > $I0 goto done
    file = argv[i]
    print "file="
    say file
    output = qx('parrot',file)
    stream = tapir.'parse_tapstream'(output)
    success = stream.'is_pass'()
    print "success="
    say success
    inc i
    goto loop
 done:
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

