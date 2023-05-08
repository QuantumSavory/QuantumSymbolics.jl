# Most of the useful functionality declared here is implemented in MixedCliffordOpticsExt

export StabilizerState, stab_to_ket

"""State defined by a stabilizer tableau

For full functionality you also need to import the `QuantumClifford` library.

```jldoctest
julia> StabilizerState(S"XX ZZ")
𝒮₂

julia> express(StabilizerState(S"-X"))
Ket(dim=2)
  basis: Spin(1/2)
  0.7071067811865475 + 0.0im
 -0.7071067811865475 + 0.0im
```"""
@withmetadata struct StabilizerState{T} <: Symbolic{AbstractKet} where {T}
    stabilizer::T
end
istree(::StabilizerState) = false
basis(x::StabilizerState) = SpinBasis(1//2)^nqubits(x.stabilizer)
Base.print(io::IO, x::StabilizerState) = print(io, "𝒮$(num_to_sub(nqubits(x.stabilizer)))")

StabilizerState(s::T) where {T} = StabilizerState{T}(s) # TODO this is necessary because the @withmetadata macro is not very smart

function stab_to_ket end
