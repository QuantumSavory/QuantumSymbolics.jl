##
# Predefined objects in the Fock space.
##

"""Fock state in defined Fock basis."""
@withmetadata struct FockState <: SpecialKet
    idx::Int
    basis::FockBasis
end
FockState(idx::Int) = FockState(idx, inf_fock_basis)
symbollabel(x::FockState) = "$(x.idx)"

"""Coherent state in defined Fock basis."""
@withmetadata struct CoherentState <: SpecialKet
    alpha::Number # TODO parameterize
    basis::FockBasis
end
CoherentState(alpha::Number) = CoherentState(alpha, inf_fock_basis)
symbollabel(x::CoherentState) = "$(x.alpha)"

"""Squeezed vacuum state in defined Fock basis."""
@withmetadata struct SqueezedState <: SpecialKet
    z::Number
    basis::FockBasis
end
SqueezedState(z::Number) = SqueezedState(z, inf_fock_basis)
symbollabel(x::SqueezedState) = "0,$(x.z)"

"""Two-mode squeezed vacuum state, or EPR state, in defined Fock basis."""
@withmetadata struct TwoSqueezedState <: SpecialKet
    z::Number
    basis::CompositeBasis
    function TwoSqueezedState(z::Number, basis::CompositeBasis)
        bases = basis.bases
        length(bases) == 2 && all(x -> x isa FockBasis, bases) || 
                throw(ArgumentError(lazy"The underlying basis for an EPR state must be a tensor product of two bases for single-mode quantum systems."))
        return new(z, basis)
    end
end
TwoSqueezedState(z::Number) = TwoSqueezedState(z, inf_fock_basis^2)
symbollabel(x::TwoSqueezedState) = "0,$(x.z)"

const inf_fock_basis = FockBasis(Inf,0.)
"""Vacuum basis state of n"""
const vac = const F₀ = const F0 = FockState(0)
"""Single photon basis state of n"""
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
@withmetadata struct NumberOp <: AbstractSingleBosonOp 
    basis::FockBasis
end
NumberOp() = NumberOp(inf_fock_basis)
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
@withmetadata struct CreateOp <: AbstractSingleBosonOp
    basis::FockBasis
end
CreateOp() = CreateOp(inf_fock_basis)
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
@withmetadata struct DestroyOp <: AbstractSingleBosonOp
    basis::FockBasis
end
DestroyOp() = DestroyOp(inf_fock_basis)
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
@withmetadata struct PhaseShiftOp <: AbstractSingleBosonOp
    phase::Number
    basis::FockBasis
end
PhaseShiftOp(phase::Number) = PhaseShiftOp(phase, inf_fock_basis)
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
@withmetadata struct DisplaceOp <: AbstractSingleBosonOp
    alpha::Number
    basis::FockBasis
end
DisplaceOp(alpha::Number) = DisplaceOp(alpha, inf_fock_basis)
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
@withmetadata struct SqueezeOp <: AbstractSingleBosonOp
    z::Number
    basis::FockBasis
end
SqueezeOp(z::Number) = SqueezeOp(z, inf_fock_basis)
symbollabel(x::SqueezeOp) = "S($(x.z))"

"""Thermal bosonic state in defined Fock basis."""
@withmetadata struct BosonicThermalState <: AbstractSingleBosonOp
    photons::Number
    basis::FockBasis
end
BosonicThermalState(photons::Number) = BosonicThermalState(photons, inf_fock_basis)
symbollabel(x::BosonicThermalState) = "ρₜₕ($(x.photons))"

"""Two-mode squeezing operator in defined Fock basis."""
@withmetadata struct TwoSqueezeOp <: AbstractTwoBosonOp
    z::Number
    basis::CompositeBasis
    function TwoSqueezeOp(z::Number, basis::CompositeBasis)
        bases = basis.bases
        length(bases) == 2 && all(x -> x isa FockBasis, bases) || 
                throw(ArgumentError(lazy"The underlying basis for a two-mode squeeze operator must be a tensor product of two bases for single-mode quantum systems."))
        return new(z, basis)
    end
end
TwoSqueezeOp(z::Number) = TwoSqueezeOp(z, inf_fock_basis^2)
symbollabel(x::TwoSqueezeOp) = "S₂($(x.z))"

"""Two-mode beamsplitter operator in defined Fock basis."""
@withmetadata struct BeamSplitterOp <: AbstractTwoBosonOp
    transmit::Number
    basis::CompositeBasis
    function BeamSplitterOp(transmit::Number, basis::CompositeBasis)
        bases = basis.bases
        length(bases) == 2 && all(x -> x isa FockBasis, bases) || 
                throw(ArgumentError(lazy"The underlying basis for a beam splitter operator must be a tensor product of two bases for single-mode quantum systems."))
        return new(transmit, basis)
    end
end
BeamSplitterOp(transmit::Number) = BeamSplitterOp(transmit, inf_fock_basis^2)
symbollabel(x::BeamSplitterOp) = "B($(x.transmit))"