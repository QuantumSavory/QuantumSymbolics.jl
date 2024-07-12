##
# Predefined objects in the Fock space.
##

"""Fock state in defined Fock basis."""
@withmetadata struct FockState <: SpecialKet
    idx::Int
    basis::FockBasis
end
symbollabel(x::FockState) = "$(x.idx)"

"""Coherent state in defined Fock basis."""
@withmetadata struct CoherentState <: SpecialKet
    alpha::Number # TODO parameterize
    basis::FockBasis
end
symbollabel(x::CoherentState) = "$(x.alpha)"

const inf_fock_basis = FockBasis(Inf,0.)
"""Vacuum basis state of n"""
const vac = const F₀ = const F0 = FockState(0,inf_fock_basis)
"""Single photon basis state of n"""
const F₁ = const F1 = FockState(1,inf_fock_basis)

##
# Gates and Operators on harmonic oscillators
##

abstract type AbstractSingleBosonOp <: Symbolic{AbstractOperator} end
abstract type AbstractSingleBosonGate <: AbstractSingleBosonOp end # TODO maybe an IsUnitaryTrait is a better choice
isexpr(::AbstractSingleBosonGate) = false
basis(x::AbstractSingleBosonOp) = x.basis
basis(::AbstractSingleBosonGate) = inf_fock_basis

"""Number operator in defined Fock basis.

```jldoctest
julia> f = FockState(2, FockBasis(4))
|2⟩

julia> num = NumberOp(FockBasis(4))
n

julia> qsimplify(num*f, rewriter=qsimplify_fock)
2|2⟩
```
"""
@withmetadata struct NumberOp <: AbstractSingleBosonOp
    basis::FockBasis
end
symbollabel(::NumberOp) = "n"

"""Creation (raising) operator in defined Fock basis.

```jldoctest
julia> f = FockState(2, FockBasis(4))
|2⟩

julia> create = CreateOp(FockBasis(4))
a†

julia> qsimplify(create*f, rewriter=qsimplify_fock)
1.7320508075688772|3⟩
```
"""
@withmetadata struct CreateOp <: AbstractSingleBosonOp
    basis::FockBasis
end
symbollabel(::CreateOp) = "a†"

"""Annihilation (lowering or destroy) operator in defined Fock basis.

```jldoctest
julia> f = FockState(2, FockBasis(4))
|2⟩

julia> destroy = DestroyOp(FockBasis(4))
a

julia> qsimplify(destroy*f, rewriter=qsimplify_fock)
1.4142135623730951|1⟩
```
"""
@withmetadata struct DestroyOp <: AbstractSingleBosonOp
    basis::FockBasis
end
symbollabel(::DestroyOp) = "a"

"""Phase-shift operator in defined Fock basis.

```jldoctest
julia> c = CoherentState(im, FockBasis(4))
|im⟩

julia> phase = PhaseShiftOp(pi, FockBasis(4))
U(π)

julia> qsimplify(phase*c, rewriter=qsimplify_fock)
|1.2246467991473532e-16 - 1.0im⟩
```
"""
@withmetadata struct PhaseShiftOp <: AbstractSingleBosonOp
    phase::Number
    basis::FockBasis
end
symbollabel(x::PhaseShiftOp) = "U($(x.phase))"

"""Displacement operator in defined Fock basis.

```jldoctest
julia> f = FockState(0, FockBasis(4))
|0⟩

julia> displace = DisplaceOp(im, FockBasis(4))
D(im)

julia> qsimplify(displace*f, rewriter=qsimplify_fock)
|im⟩
```
"""
@withmetadata struct DisplaceOp <: AbstractSingleBosonOp
    alpha::Number
    basis::FockBasis
end
symbollabel(x::DisplaceOp) = "D($(x.alpha))"

"""Number operator, also available as the constant `n̂`, in an infinite dimension Fock basis."""
const N = const n̂ = NumberOp(inf_fock_basis)
"""Creation operator, also available as the constant `âꜛ`, in an infinite dimension Fock basis.
There is no unicode dagger superscript, so we use the uparrow"""
const Create = const âꜛ = CreateOp(inf_fock_basis)
"""Annihilation operator, also available as the constant `â`, in an infinite dimension Fock basis."""
const Destroy = const â = DestroyOp(inf_fock_basis)