# Copyright (C) 2009, Jonathan "Duke" Leto

=head1 AUTHOR

Written and maintained by Jonathan "Duke" Leto C<< jonathan@leto.net >>.

=cut

.namespace [ 'Tapir'; 'Parser' ]

#.sub _initialize :load
#
#    .local pmc parser
#    set_hll_global [ 'Tapir'; 'Parser' ], '_parser', parser
#.end

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

