# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.namespace [ 'Tapir'; 'Stream' ]

.sub _initialize :load :method
    addattribute self, "pass"
    addattribute self, "fail"
    addattribute self, "todo"
    addattribute self, "skip"
    addattribute self, "plan"
.end

.sub set_pass :method
    .param pmc pass
    setattribute self, "pass", pass
.end

.sub set_fail :method
    .param pmc fail
    setattribute self, "fail", fail
.end

.sub set_todo :method
    .param pmc todo
    setattribute self, "todo", todo
.end

.sub set_skip :method
    .param pmc skip
    setattribute self, "skip", skip
.end

.sub set_plan :method
    .param pmc plan
    setattribute self, "plan", plan
.end

.sub get_pass :method
    .param pmc pass
    pass = getattribute self, "pass"
    .return( pass )
.end

.sub get_fail :method
    .param pmc fail
    fail = getattribute self, "fail"
    .return( fail )
.end

.sub get_todo :method
    .param pmc todo
    todo = getattribute self, "todo"
    .return( todo )
.end

.sub get_skip :method
    .param pmc skip
    skip = getattribute self, "skip"
    .return( skip )
.end

.sub get_plan :method
    .param pmc plan
    plan = getattribute self, "plan"
    .return( plan )
.end

.sub total :method
    .local pmc skip, pass, fail, todo
    skip = getattribute self, "skip"
    pass = getattribute self, "pass"
    fail = getattribute self, "fail"
    todo = getattribute self, "todo"
    $P0  = pass + fail
    $P0 += todo
    $P0 += skip
    .return( $P0 )
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

