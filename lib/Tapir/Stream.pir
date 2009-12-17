# Copyright (C) 2009, Jonathan "Duke" Leto <jonathan@leto.net>

.namespace [ 'Tapir'; 'Stream' ]

# 06:28:33 <@chromatic> :load executes only when loading from bytecode.
# 06:28:48 <@chromatic> :init executes right after compilation.
# 06:29:17 <@chromatic> The effects of :init should be frozen into PBC.
# 06:37:26 <@chromatic> :anon :init trips the "Do something special with bytecode" magic.

.sub _initialize :load :anon
    .local pmc klass

    klass  = newclass [ 'Tapir'; 'Stream' ]
    klass.'add_attribute'('pass')
    klass.'add_attribute'('fail')
    klass.'add_attribute'('skip')
    klass.'add_attribute'('todo')
    klass.'add_attribute'('plan')
    klass.'add_attribute'('exit_code')
.end

.sub is_pass :method
    .local pmc fail
    fail = getattribute self, "fail"
    if fail goto failz

    .local pmc exit_code
    exit_code = self."get_exit_code"()
    if exit_code goto failz

    .local pmc skip, pass, todo, plan
    skip  = self."get_skip"()
    pass  = self."get_pass"()
    todo  = self."get_todo"()
    plan  = self."get_plan"()
    $P0   = pass + todo
    $P0  += skip

    $I1 = plan == $P0
    .return( $I1 )
  failz:
    .return( 0 )
.end

.sub set_exit_code :method
    .param pmc exit_code
    setattribute self, "exit_code", exit_code
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

.sub get_exit_code :method
    .local pmc exit_code
    exit_code = getattribute self, "exit_code"
    .return( exit_code )
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

