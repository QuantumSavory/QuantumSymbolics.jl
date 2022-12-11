# This file contains types that depend on multiple backends
# or types for whom even the symbolic representation depends on a backend.

using QSymbolicsBase: @withmetadata, Metadata,
    AbstractKet, num_to_sub,
    Symbolic
import QSymbolicsBase: express, express_nolookup, basis
import QSymbolicsBase: istree, exprhead, operation, arguments, similarterm, metadata # actually from TermInterface
using QSymbolicsClifford: graphstate, stabilizerview, Stabilizer, MixedDestabilizer
using QuantumClifford: _T_str
using QuantumInterface: nqubits, apply!, SpinBasis, nqubits
using Graphs: edges
using QSymbolicsOptics: _cphase, _z, _phase, _hadamard, _s₊

export StabilizerState, stab_to_ket

"""State defined by a stabilizer tableau

```jldoctest
julia> StabilizerState(S"XX ZZ")
𝒮₂

julia> express(StabilizerState(S"-X"))
Ket(dim=2)
  basis: Spin(1/2)
  0.7071067811865475 + 0.0im
 -0.7071067811865475 + 0.0im
```"""
@withmetadata struct StabilizerState <: Symbolic{AbstractKet}
    stabilizer::MixedDestabilizer
end
function StabilizerState(x::Stabilizer)
    r,c = size(x)
    @assert r==c
    StabilizerState(MixedDestabilizer(x))
end
StabilizerState(x::String) = StabilizerState(Stabilizer(_T_str(x)))
istree(::StabilizerState) = false
basis(x::StabilizerState) = SpinBasis(1//2)^nqubits(x.stabilizer)
Base.print(io::IO, x::StabilizerState) = print(io, "𝒮$(num_to_sub(nqubits(x.stabilizer)))")

express_nolookup(x::StabilizerState, ::CliffordRepr) = copy(x.stabilizer)

function stab_to_ket(s::Stabilizer)
    r,c = size(s)
    @assert r==c
    graph, hadamard_idx, iphase_idx, flips_idx = graphstate(s)
    ket = tensor(fill(copy(_s₊),c)...) # TODO fix this is UGLY
    for (;src,dst) in edges(graph)
        apply!(ket, [src,dst], _cphase)
    end
    for i in flips_idx
        apply!(ket, [i], _z)
    end
    for i in iphase_idx
        apply!(ket, [i], _phase)
    end
    for i in hadamard_idx
        apply!(ket, [i], _hadamard)
    end
    ket
end

express_nolookup(x::StabilizerState, ::QuantumOpticsRepr) = stab_to_ket(stabilizerview(x.stabilizer))
