export PauliNoiseCPTP, DephasingCPTP, DephasingCPTP, GateCPTP

abstract type NoiseCPTP <: Symbolic{AbstractSuperOperator} end
isexpr(::NoiseCPTP) = false
basis(x::NoiseCPTP) = x.basis

"""Single-qubit Pauli noise CPTP map

```jldoctest
julia> apply!(express(Z1), [1], express(PauliNoiseCPTP(1/4,1/4,1/4)))
Operator(dim=2x2)
  basis: Spin(1/2)
 0.5+0.0im  0.0+0.0im
 0.0+0.0im  0.5+0.0im
```"""
@withmetadata struct PauliNoiseCPTP <: NoiseCPTP
    px
    py
    pz
end
basis(x::PauliNoiseCPTP) = SpinBasis(1//2)
symbollabel(x::PauliNoiseCPTP) = "𝒫"

"""Single-qubit dephasing CPTP map"""
@withmetadata struct DephasingCPTP <: NoiseCPTP
    p
end
basis(x::DephasingCPTP) = SpinBasis(1//2)
symbollabel(x::DephasingCPTP) = "𝒟𝓅𝒽"

"""Single-qubit depolarization CPTP map"""
@withmetadata struct DepolarizationCPTP <: NoiseCPTP
    p
    basis::Basis
end
symbollabel(x::DepolarizationCPTP) = "𝒟ℯ𝓅ℴ𝓁"

"""A unitary gate followed by a CPTP map"""
@withmetadata struct GateCPTP <: NoiseCPTP
    gate::Symbolic{AbstractOperator}
    cptp::NoiseCPTP
end
basis(x::GateCPTP) = basis(x.cptp)
function Base.show(io::IO, x::GateCPTP)
    print(io, x.cptp)
    print(io, "[")
    print(io, x.gate)
    print(io, "]")
end

##
# Representations of CPTP maps
##

"""Kraus representation of a quantum channel

```jldoctest
julia> @superop ℰ;

julia> @op A₁; @op A₂; @op A₃;

julia> K = kraus(ℰ, A₁, A₂, A₃);

julia> @op ρ;

julia> K*ρ
(A₁ρA₁†+A₂ρA₂†+A₃ρA₃†)
```
"""
@withmetadata struct KrausRepr <: Symbolic{AbstractSuperOperator}
    sop
    krausops
end
isexpr(::KrausRepr) = true
iscall(::KrausRepr) = true
arguments(x::KrausRepr) = [x.sop, x.krausops]
operation(x::KrausRepr) = kraus
head(x::KrausRepr) = :kraus
children(x::KrausRepr) = [:kraus, x.sop, x.krausops]
kraus(s::Symbolic{AbstractSuperOperator}, xs::Symbolic{AbstractOperator}...) = KrausRepr(s,collect(xs))
symbollabel(x::KrausRepr) = symbollabel(x.sop)
basis(x::KrausRepr) = basis(x.sop)
Base.show(io::IO, x::KrausRepr) = print(io, symbollabel(x))