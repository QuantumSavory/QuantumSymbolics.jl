export PauliNoiseCPTP, DephasingCPTP, DephasingCPTP, GateCPTP, AttenuatorCPTP, AmplifierCPTP

abstract type NoiseCPTP <: Symbolic{AbstractSuperOperator} end
isexpr(::NoiseCPTP) = false
basis(x::NoiseCPTP) = x.basis

"""
    AttenuatorCPTP(theta::Number, noise::Int)

Attenuation CPTP map, defined by the beam splitter rotation parameter `theta`
and thermal noise parameter `noise`.
"""
@withmetadata struct AttenuatorCPTP <: NoiseCPTP
    theta::Real
    noise::Real
end
basis(x::AttenuatorCPTP) = inf_fock_basis
symbollabel(x::AttenuatorCPTP) = "𝒜𝓉𝓉"

"""
    AmplifierCPTP(r::Number, noise::Int)

Amplification CPTP map, defined by the squeezing amplitude parameter `r`
and thermal noise parameter `noise`.
"""
@withmetadata struct AmplifierCPTP <: NoiseCPTP
    r::Real
    noise::Real
end
basis(x::AmplifierCPTP) = inf_fock_basis
symbollabel(x::AmplifierCPTP) = "𝒜𝓂𝓅"

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
