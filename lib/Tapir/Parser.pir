# Copyright (C) 2009, Jonathan "Duke" Leto

=head1 AUTHOR

Written and maintained by Jonathan "Duke" Leto C<< jonathan@leto.net >>.

=cut

.namespace [ 'Tapir'; 'Parser' ]

.sub bail_if_necessary :method
    .param string line
    $S0 = substr line, 0, 9
    if $S0 == 'Bail out!' goto bail_out
    .return(0)
  bail_out:
    .return(1)
.end

.sub parse_tapstream :method
    .param string tap
    .param int exit_code :optional
    .local string curr_line
    .local pmc plan, pass, fail, skip, todo
    .local int i, curr_test, reported_test, ordered, num_lines
    .local pmc tap_lines, parts, klass, stream

    i         = 0
    curr_test = 1
    ordered   = 1
    fail      = new 'Integer'
    skip      = new 'Integer'
    todo      = new 'Integer'
    pass      = new 'Integer'
    plan      = new 'Integer'
    tap_lines = new 'ResizablePMCArray'
    parts     = new 'ResizablePMCArray'

    split tap_lines, "\n", tap
    num_lines = tap_lines

    .local string plan_line
    plan_line = tap_lines[0]
    plan      = self.'parse_plan'(plan_line)

    .local string prefix
  loop:
    if i >= num_lines goto done
    curr_line = tap_lines[i]

    .local int need_to_bail
    need_to_bail = self.'bail_if_necessary'(curr_line)
    if need_to_bail goto done

    .local int is_tap
    is_tap = self.'is_tap'(curr_line)
    unless is_tap goto unrecognized

    split parts, "ok ", curr_line

    prefix        = parts[0]
    reported_test = parts[1]

    if prefix == 'not ' goto fail_or_todo

    if reported_test == curr_test goto pass_or_skip
    # out of order test
    ordered = 0

  unrecognized: # doesn't look like TAP, just ignore
    inc i
    goto loop
  pass_or_skip:
    split parts, "# ", curr_line
    $S0 = parts[1]
    $S0 = substr $S0, 0, 4
    downcase $S0
    if $S0 != "skip" goto passz
    # it is a SKIP test!
    inc skip
    inc i
    inc curr_test
    goto loop
  fail_or_todo:
    split parts, "# ", curr_line
    $S0 = parts[1]
    $S0 = substr $S0, 0, 4
    downcase $S0
    if $S0 != "todo" goto failz
    # it is a TODO test!
    inc todo
    inc curr_test
    inc i
    goto loop
  failz:
    inc fail
    inc curr_test
    inc i
    goto loop
  passz:
    inc pass
    inc i
    inc curr_test
    goto loop

  done:
    stream = new [ 'Tapir'; 'Stream' ]
    stream.'set_pass'(pass)
    stream.'set_fail'(fail)
    stream.'set_todo'(todo)
    stream.'set_skip'(skip)
    stream.'set_plan'(plan)
    stream.'set_exit_code'(exit_code)
    .return (stream)
.end

.sub is_tap :method
    .param string tapline
    $S0 = substr tapline, 0, 3
    if $S0 == "ok " goto yes

    $S0 = substr tapline, 0, 7
    if $S0 == "not ok " goto yes

    no:
        .return( 0 )
    yes:
        .return( 1 )
.end

# parse_plan returns the expected number of tests given a plan line as a string

.sub parse_plan :method
    .param string plan_line
    .local pmc plan_parts
    # yes, a numeric
    .local num num_expected_tests

    $I0 = length plan_line
    if $I0 < 4 goto plan_error

    # this needs to take into account TAP Versions
    $S0 = substr plan_line, 0, 3
    unless $S0 == "1.." goto plan_error

    plan_parts = new 'FixedPMCArray'
    plan_parts = 2

    split plan_parts, "..", plan_line
    num_expected_tests  = plan_parts[1]

    $I1 = num_expected_tests
    unless $I1 == num_expected_tests goto plan_error
    .return (num_expected_tests)
  plan_error:
    # this indicates an invalid plan
    .return (-1)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

