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

"""Squeezed coherent state in defined Fock basis."""
@withmetadata struct SqueezedCoherentState <: SpecialKet
    alpha::Number
    z::Number
    basis::FockBasis
end
SqueezedCoherentState(alpha::Number, z::Number) = SqueezedCoherentState(alpha, z, inf_fock_basis)
symbollabel(x::SqueezedCoherentState) = "$(x.alpha),$(x.z)"

const inf_fock_basis = FockBasis(Inf,0.)
"""Vacuum basis state of n"""
const vac = const F₀ = const F0 = FockState(0)
"""Single photon basis state of n"""
const F₁ = const F1 = FockState(1)

##
# Gates and Operators on harmonic oscillators
##

abstract type AbstractSingleBosonOp <: Symbolic{AbstractOperator} end
abstract type AbstractSingleBosonGate <: AbstractSingleBosonOp end # TODO maybe an IsUnitaryTrait is a better choice
isexpr(::AbstractSingleBosonGate) = false
basis(x::AbstractSingleBosonOp) = inf_fock_basis

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
julia> c = CoherentState(im)
|im⟩

julia> S = SqueezeOp(pi)
S(π)

julia> qsimplify(S*c, rewriter=qsimplify_fock)
|im,π⟩
```
"""
@withmetadata struct SqueezeOp <: AbstractSingleBosonOp
    z::Number
    basis::FockBasis
end
SqueezeOp(z::Number) = SqueezeOp(z, inf_fock_basis)
symbollabel(x::SqueezeOp) = "S($(x.z))"