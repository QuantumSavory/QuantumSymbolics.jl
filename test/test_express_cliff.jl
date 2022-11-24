using Test
using QSymbolics
using QuantumClifford

state = StabilizerState(S"ZZ XX")
state = SProjector(state)*0.5 + 0.5*MixedState(state)
state2 = deepcopy(state)
express(state, CliffordRepr())
express(state, CliffordRepr())
express(state2)
express(state2)
nocache = @timed express(state2, CliffordRepr())
withcache = @timed express(state2, CliffordRepr())
@test nocache.time > 2*withcache.time
@test withcache.bytes <= 200
results = Set([express(state2, CliffordRepr()) for i in 1:20])
@test length(results)==2
