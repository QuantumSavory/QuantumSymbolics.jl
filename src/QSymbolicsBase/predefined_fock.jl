##
# Predefined objects in the Fock space.
##

const inf_fock_basis = FockBasis(Inf,0.0) # Inf is Float, so the second parameter has to be Float too

abstract type AbstractSingleBosonState <: SpecialKet end
abstract type AbstractTwoBosonState <: SpecialKet end
basis(::AbstractSingleBosonState) = inf_fock_basis
basis(::AbstractTwoBosonState) = inf_fock_basis^2

"""Fock state in defined Fock basis."""
@withmetadata struct FockState <: AbstractSingleBosonState
    idx::Int
end
symbollabel(x::FockState) = "$(x.idx)"

"""Coherent state in defined Fock basis."""
@withmetadata struct CoherentState <: AbstractSingleBosonState
    alpha::Number # TODO parameterize
end
symbollabel(x::CoherentState) = "$(x.alpha)"

"""Squeezed vacuum state in defined Fock basis."""
@withmetadata struct SqueezedState <: AbstractSingleBosonState
    z::Number
end
symbollabel(x::SqueezedState) = "0,$(x.z)"

"""Two-mode squeezed vacuum state, or EPR state, in defined Fock basis."""
@withmetadata struct TwoSqueezedState <: AbstractTwoBosonState
    z::Number
end
symbollabel(x::TwoSqueezedState) = "0,$(x.z)"

"""Single-mode vacuum state"""
const vac = const F₀ = const F0 = FockState(0)
"""Single photon state"""
const F₁ = const F1 = FockState(1)

##
# Gates and Operators on harmonic oscillators
##

abstract type AbstractSingleBosonOp <: Symbolic{AbstractOperator} end
abstract type AbstractTwoBosonOp <: Symbolic{AbstractOperator} end
abstract type AbstractSingleBosonGate <: AbstractSingleBosonOp end # TODO maybe an IsUnitaryTrait is a better choice
abstract type AbstractTwoBosonGate <: AbstractTwoBosonOp end
isexpr(::AbstractSingleBosonGate) = false
basis(x::AbstractSingleBosonOp) = inf_fock_basis
isexpr(::AbstractTwoBosonGate) = false
basis(x::AbstractTwoBosonOp) = inf_fock_basis^2

"""Number operator.

```jldoctest
julia> f = FockState(2)
|2⟩

julia> num = NumberOp()
n

julia> qsimplify(num*f, rewriter=qsimplify_fock)
2|2⟩
```
"""
@withmetadata struct NumberOp <: AbstractSingleBosonOp end
symbollabel(::NumberOp) = "n"

"""Creation (raising) operator.

```jldoctest
julia> f = FockState(2)
|2⟩

julia> create = CreateOp()
a†

julia> qsimplify(create*f, rewriter=qsimplify_fock)
(sqrt(3))|3⟩
```
"""
@withmetadata struct CreateOp <: AbstractSingleBosonOp end
symbollabel(::CreateOp) = "a†"

"""Annihilation (lowering or destroy) operator in defined Fock basis.

```jldoctest
julia> f = FockState(2)
|2⟩

julia> destroy = DestroyOp()
a

julia> qsimplify(destroy*f, rewriter=qsimplify_fock)
(sqrt(2))|1⟩
```
"""
@withmetadata struct DestroyOp <: AbstractSingleBosonOp end
symbollabel(::DestroyOp) = "a"

"""Phase-shift operator in defined Fock basis.

```jldoctest
julia> c = CoherentState(im)
|im⟩

julia> phase = PhaseShiftOp(pi)
U(π)

julia> qsimplify(phase*c, rewriter=qsimplify_fock)
|1.2246467991473532e-16 - 1.0im⟩
```
"""
@withmetadata struct PhaseShiftOp <: AbstractSingleBosonGate
    phase::Number
end
symbollabel(x::PhaseShiftOp) = "U($(x.phase))"

"""Displacement operator in defined Fock basis.

```jldoctest
julia> f = FockState(0)
|0⟩

julia> displace = DisplaceOp(im)
D(im)

julia> qsimplify(displace*f, rewriter=qsimplify_fock)
|im⟩
```
"""
@withmetadata struct DisplaceOp <: AbstractSingleBosonGate
    alpha::Number
end
symbollabel(x::DisplaceOp) = "D($(x.alpha))"

"""Number operator, also available as the constant `n̂`, in an infinite dimension Fock basis."""
const N = const n̂ = NumberOp()
"""Creation operator, also available as the constant `âꜛ`, in an infinite dimension Fock basis.
There is no unicode dagger superscript, so we use the uparrow"""
const Create = const âꜛ = CreateOp()
"""Annihilation operator, also available as the constant `â`, in an infinite dimension Fock basis."""
const Destroy = const â = DestroyOp()

"""Squeezing operator in defined Fock basis.

```jldoctest
julia> S = SqueezeOp(pi)
S(π)

julia> qsimplify(S*vac, rewriter=qsimplify_fock)
|0,π⟩
```
"""
@withmetadata struct SqueezeOp <: AbstractSingleBosonGate
    z::Number
end
symbollabel(x::SqueezeOp) = "S($(x.z))"

"""Thermal bosonic state in defined Fock basis."""
@withmetadata struct BosonicThermalState <: AbstractSingleBosonOp
    photons::Number
end
symbollabel(x::BosonicThermalState) = "ρₜₕ($(x.photons))"

"""Two-mode squeezing operator in defined Fock basis."""
@withmetadata struct TwoSqueezeOp <: AbstractTwoBosonGate
    z::Number
end
symbollabel(x::TwoSqueezeOp) = "S₂($(x.z))"

"""Two-mode beamsplitter operator in defined Fock basis."""
@withmetadata struct BeamSplitterOp <: AbstractTwoBosonGate
    transmit::Number
end
symbollabel(x::BeamSplitterOp) = "B($(x.transmit))"