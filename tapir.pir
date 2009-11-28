# Copyright (C) 2009, Jonathan "Duke" Leto

=head1 AUTHOR

Written and maintained by Jonathan "Duke" Leto C<< jonathan@leto.net >>.

=cut

.sub main :main
    .local int num_tests
    $S0 = "1..5\nFoobar!"
    num_tests = parse_plan($S0)
    say num_tests
.end

.sub parse_tests
    .param string tap
    .local string curr_line, delim
    .local int passed, failed, skipped, todoed
    .local int i
    .local int curr_test
    .local pmc tap_lines
    .local pmc parts
    i = 1

    tap_lines = new 'ResizablePMCArray'
    parts     = new 'ResizablePMCArray'
    delim               = "\n"
    split tap_lines, delim, tap

  loop:
    curr_line = tap_lines[i]
    unless curr_line goto done
    delim    = "ok "

    split parts, delim, curr_line
    curr_test = parts[1]
    # check curr_test for comments
    inc i
    goto loop

  done:
    .return (passed,failed,skipped,todoed)
.end

.sub parse_plan
    .param string tap
    .local pmc tap_lines
    .local pmc plan_parts
    .local int num_expected_tests
    .local string delim
    .local string plan

    tap_lines = new 'ResizablePMCArray'
    delim               = "\n"
    split tap_lines, delim, tap
    plan                = tap_lines[0]
    unless plan goto error
    delim               = ".."
    plan_parts = new 'ResizablePMCArray'
    split plan_parts, delim, plan

    unless plan_parts goto plan_error
    num_expected_tests  = plan_parts[1]

    .return (num_expected_tests)
  error:
    die 'Invalid TAP Stream, no plan found'
  plan_error:
    die 'Invalid TAP Plan'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

