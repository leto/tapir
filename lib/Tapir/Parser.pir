# Copyright (C) 2009, Jonathan "Duke" Leto

=head1 AUTHOR

Written and maintained by Jonathan "Duke" Leto C<< jonathan@leto.net >>.

=cut

.namespace [ 'Tapir'; 'Parser' ]

.sub parse_tapstream :method
    .param string tap
    .local string curr_line, delim
    .local pmc plan, pass, fail, skip, todo
    .local int i, curr_test
    .local pmc tap_lines, parts, klass, stream
    i = 0
    fail = new 'Integer'
    skip = new 'Integer'
    todo = new 'Integer'
    pass = new 'Integer'
    plan = new 'Integer'

    plan = self.'parse_plan'(tap)

    tap_lines = new 'ResizablePMCArray'
    parts     = new 'ResizablePMCArray'
    delim               = "\n"
    split tap_lines, delim, tap
    $I0 = tap_lines

  loop:
    if i >= $I0 goto done
    curr_line = tap_lines[i]
    unless curr_line goto done
    delim    = "ok "

    split parts, delim, curr_line

    .local string prefix
    prefix    = parts[0]
    curr_test = parts[1]

    if prefix == 'not ' goto failz

    if curr_test == i goto got_pass
    goto loop
  got_pass:
    # check curr_test for comments
    inc pass
    inc i
    goto loop
  failz:
    inc fail
    inc i
    goto loop

  done:
    # XXX hack
    dec pass # passes get mis-counted by 1

    stream = new [ 'Tapir'; 'Stream' ]
    stream.'set_pass'(pass)
    stream.'set_fail'(fail)
    stream.'set_todo'(todo)
    stream.'set_skip'(skip)
    stream.'set_plan'(plan)
    .return (stream)
.end

# parse_plan returns the expected number of test given a TAP stream as a string

.sub parse_plan :method
    .param string tap
    .local pmc plan_line
    .local pmc plan_parts
    .local int num_expected_tests
    .local string delim
    .local string plan

    plan_line = new 'ResizablePMCArray'
    delim               = "\n"
    split plan_line, delim, tap
    plan                 = plan_line[0]
    unless plan goto error
    delim               = ".."
    plan_parts = new 'ResizablePMCArray'
    split plan_parts, delim, plan

    unless plan_parts goto plan_error
    num_expected_tests  = plan_parts[1]

    .return (num_expected_tests)
  error:
    die 'Invalid TAP Stream'
  plan_error:
    die 'Invalid TAP Plan'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

