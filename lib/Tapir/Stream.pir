# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.namespace [ 'Tapir'; 'Stream' ]

.sub _initialize :load :init
    #say "Initializing!"
    .local pmc klass

    klass  = newclass [ 'Tapir'; 'Stream' ]
    klass.'add_attribute'('pass')
    klass.'add_attribute'('fail')
    klass.'add_attribute'('skip')
    klass.'add_attribute'('todo')
    klass.'add_attribute'('plan')
.end

.sub is_pass :method
    .local pmc fail
    fail = getattribute self, "fail"
    if fail goto failz

    .local pmc skip, pass, todo, plan
    skip = getattribute self, "skip"
    pass = getattribute self, "pass"
    todo = getattribute self, "todo"
    plan = getattribute self, "plan"
    $P0  = pass + todo
    $P0 += todo

    $I1 = plan == $P0
    .return( $I1 )
  failz:
    .return( 0 )
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
    .local pmc pass
    pass = getattribute self, "pass"
    .return( pass )
.end

.sub get_fail :method
    .local pmc fail
    fail = getattribute self, "fail"
    .return( fail )
.end

.sub get_todo :method
    .local pmc todo
    todo = getattribute self, "todo"
    .return( todo )
.end

.sub get_skip :method
    .local pmc skip
    skip = getattribute self, "skip"
    .return( skip )
.end

.sub get_plan :method
    .local pmc plan
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

