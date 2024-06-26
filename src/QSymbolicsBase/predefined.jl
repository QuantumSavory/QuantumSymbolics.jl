##
# Pure States
##

abstract type SpecialKet <: Symbolic{AbstractKet} end
isexpr(::SpecialKet) = false
basis(x::SpecialKet) = x.basis
Base.show(io::IO, x::SpecialKet) = print(io, "|$(symbollabel(x))⟩")

@withmetadata struct XBasisState <: SpecialKet
    idx::Int
    basis::Basis
end
symbollabel(x::XBasisState) = "X$(num_to_sub(x.idx))"

@withmetadata struct YBasisState <: SpecialKet
    idx::Int
    basis::Basis
end
symbollabel(x::YBasisState) = "Y$(num_to_sub(x.idx))"

@withmetadata struct ZBasisState <: SpecialKet
    idx::Int
    basis::Basis
end
symbollabel(x::ZBasisState) = "Z$(num_to_sub(x.idx))"

@withmetadata struct FockBasisState <: SpecialKet
    idx::Int
    basis::Basis
end
symbollabel(x::FockBasisState) = "$(x.idx)"

@withmetadata struct DiscreteCoherentState <: SpecialKet
    alpha::Number # TODO parameterize
    basis::Basis
end
symbollabel(x::DiscreteCoherentState) = "$(x.alpha)"

@withmetadata struct ContinuousCoherentState <: SpecialKet
    alpha::Number # TODO parameterize
    basis::Basis
end
symbollabel(x::ContinuousCoherentState) = "$(x.alpha)"

@withmetadata struct MomentumEigenState <: SpecialKet
    p::Number # TODO parameterize
    basis::Basis
end
symbollabel(x::MomentumEigenState) = "δₚ($(x.p))"

@withmetadata struct PositionEigenState <: SpecialKet
    x::Float64 # TODO parameterize
    basis::Basis
end
symbollabel(x::PositionEigenState) = "δₓ($(x.x))"

const qubit_basis = SpinBasis(1//2)
"""Basis state of σˣ"""
const X1 = const X₁ = const Lp = const L₊ = XBasisState(1, qubit_basis)
"""Basis state of σˣ"""
const X2 = const X₂ = const Lm = const L₋ = XBasisState(2, qubit_basis)
"""Basis state of σʸ"""
const Y1 = const Y₁ = const Lpi = const L₊ᵢ = YBasisState(1, qubit_basis)
"""Basis state of σʸ"""
const Y2 = const Y₂ = const Lmi = const L₋ᵢ = YBasisState(2, qubit_basis)
"""Basis state of σᶻ"""
const Z1 = const Z₁ = const L0 = const L₀ = ZBasisState(1, qubit_basis)
"""Basis state of σᶻ"""
const Z2 = const Z₂ = const L1 = const L₁ = ZBasisState(2, qubit_basis)

const inf_fock_basis = FockBasis(Inf,0.)
"""Vacuum basis state of n"""
const vac = const F₀ = const F0 = FockBasisState(0,inf_fock_basis)
"""Single photon basis state of n"""
const F₁ = const F1 = FockBasisState(1,inf_fock_basis)


##
# Gates and Operators on qubits
##

abstract type AbstractSingleQubitOp <: Symbolic{AbstractOperator} end
abstract type AbstractTwoQubitOp <: Symbolic{AbstractOperator} end
abstract type AbstractSingleQubitGate <: AbstractSingleQubitOp end # TODO maybe an IsUnitaryTrait is a better choice
abstract type AbstractTwoQubitGate <: AbstractTwoQubitOp end
isexpr(::AbstractSingleQubitGate) = false
isexpr(::AbstractTwoQubitGate) = false
basis(::AbstractSingleQubitGate) = qubit_basis
basis(::AbstractTwoQubitGate) = qubit_basis⊗qubit_basis
Base.show(io::IO, x::AbstractSingleQubitOp) = print(io, "$(symbollabel(x))")
Base.show(io::IO, x::AbstractTwoQubitOp) = print(io, "$(symbollabel(x))")

@withmetadata struct OperatorEmbedding <: Symbolic{AbstractOperator}
    gate::Symbolic{AbstractOperator} # TODO parameterize
    indices::Vector{Int}
    basis::Basis
end
isexpr(::OperatorEmbedding) = true

@withmetadata struct XGate <: AbstractSingleQubitGate end
eigvecs(g::XGate) = [X1,X2]
symbollabel(::XGate) = "X"
ishermitian(::XGate) = true
isunitary(::XGate) = true

@withmetadata struct YGate <: AbstractSingleQubitGate end
eigvecs(g::YGate) = [Y1,Y2]
symbollabel(::YGate) = "Y"
ishermitian(::YGate) = true
isunitary(::YGate) = true

@withmetadata struct ZGate <: AbstractSingleQubitGate end
eigvecs(g::ZGate) = [Z1,Z2]
symbollabel(::ZGate) = "Z"
ishermitian(::ZGate) = true
isunitary(::ZGate) = true

@withmetadata struct PauliM <: AbstractSingleQubitGate end
symbollabel(::PauliM) = "σ₋"
ishermitian(::PauliM) = true
isunitary(::PauliM) = true

@withmetadata struct PauliP <: AbstractSingleQubitGate end
symbollabel(::PauliP) = "σ₊"
ishermitian(::PauliP) = true
isunitary(::PauliP) = true

@withmetadata struct HGate <: AbstractSingleQubitGate end
symbollabel(::HGate) = "H"
ishermitian(::HGate) = true
isunitary(::HGate) = true

@withmetadata struct CNOTGate <: AbstractTwoQubitGate end
symbollabel(::CNOTGate) = "CNOT"
ishermitian(::CNOTGate) = true
isunitary(::CNOTGate) = true

@withmetadata struct CPHASEGate <: AbstractTwoQubitGate end
symbollabel(::CPHASEGate) = "CPHASE"
ishermitian(::CPHASEGate) = true
isunitary(::CPHASEGate) = true

const xyzsuplabeldict = Dict(:X=>"ˣ",:Y=>"ʸ",:Z=>"ᶻ")
for control in (:X, :Y, :Z)
    for target in (:X, :Y, :Z)
        structname = Symbol(control,"C",target,"Gate")
        label = xyzsuplabeldict[control]*"C"*xyzsuplabeldict[target]
        declare = :(@withmetadata struct $structname <: AbstractTwoQubitGate end)
        defsymlabel = :(symbollabel(::$structname) = $label)
        instancename = Symbol(control,"C",target)
        definstance = :(const $instancename = $structname())
        eval(declare)
        eval(defsymlabel)
        eval(definstance)
    end
end

"""Pauli X operator, also available as the constant `σˣ`"""
const X = const σˣ = XGate()
"""Pauli Y operator, also available as the constant `σʸ`"""
const Y = const σʸ = YGate()
"""Pauli Z operator, also available as the constant `σᶻ`"""
const Z = const σᶻ = ZGate()
"""Pauli "minus" operator, also available as the constant `σ₋`"""
const Pm = const σ₋ = PauliM()
"""Pauli "plus" operator, also available as the constant `σ₊`"""
const Pp = const σ₊ = PauliP()
"""Hadamard gate"""
const H = HGate()
"""CNOT gate"""
const CNOT = CNOTGate()
"""CPHASE gate"""
const CPHASE = CPHASEGate()

##
# Gates and Operators on harmonic oscillators
##

abstract type AbstractSingleBosonOp <: Symbolic{AbstractOperator} end
abstract type AbstractSingleBosonGate <: AbstractSingleBosonOp end # TODO maybe an IsUnitaryTrait is a better choice
isexpr(::AbstractSingleBosonGate) = false
basis(::AbstractSingleBosonGate) = inf_fock_basis

@withmetadata struct NumberOp <: AbstractSingleBosonOp end
symbollabel(::NumberOp) = "n"
@withmetadata struct CreateOp <: AbstractSingleBosonOp end
symbollabel(::CreateOp) = "a†"
@withmetadata struct DestroyOp <: AbstractSingleBosonOp end
symbollabel(::DestroyOp) = "a"

"""Number operator, also available as the constant `n̂`"""
const N = const n̂ = NumberOp()
"""Creation operator, also available as the constant `âꜛ` - there is no unicode dagger superscript, so we use the uparrow"""
const Create = const âꜛ = CreateOp()
"""Annihilation operator, also available as the constant `â`"""
const Destroy = const â = DestroyOp()

##
# Other special or useful objects
##

"""Projector for a given ket

```jldoctest
julia> SProjector(X1⊗X2)
𝐏[|X₁⟩|X₂⟩]

julia> express(SProjector(X2))
Operator(dim=2x2)
  basis: Spin(1/2)
  0.5+0.0im  -0.5-0.0im
 -0.5+0.0im   0.5+0.0im
```"""
@withmetadata struct SProjector <: Symbolic{AbstractOperator}
    ket::Symbolic{AbstractKet} # TODO parameterize
end
isexpr(::SProjector) = true
iscall(::SProjector) = true
arguments(x::SProjector) = [x.ket]
operation(x::SProjector) = projector
head(x::SProjector) = :projector
children(x::SProjector) = [:projector,x.ket]
projector(x::Symbolic{AbstractKet}) = SProjector(x)
projector(x::SZeroKet) = SZeroOperator()
basis(x::SProjector) = basis(x.ket)
function Base.show(io::IO, x::SProjector)
    print(io,"𝐏[")
    print(io,x.ket)
    print(io,"]")
end

"""Dagger, i.e., adjoint of quantum objects (kets, bras, operators)

```jldoctest 
julia> @ket a; @op A;

julia> dagger(2*im*A*a)
0 - 2im|a⟩†A†

julia> @op B;

julia> dagger(A*B)
B†A†

julia> ℋ = SHermitianOperator(:ℋ); U = SUnitaryOperator(:U);

julia> dagger(ℋ)
ℋ

julia> dagger(U) 
U⁻¹
```
"""
@withmetadata struct SDagger{T<:QObj} <: Symbolic{T}
    obj
end
isexpr(::SDagger) = true
iscall(::SDagger) = true
arguments(x::SDagger) = [x.obj]
operation(x::SDagger) = dagger
head(x::SDagger) = :dagger
children(x::SDagger) = [:dagger, x.obj]
dagger(x::Symbolic{AbstractBra}) = SDagger{AbstractKet}(x)
dagger(x::Symbolic{AbstractKet}) = SDagger{AbstractBra}(x)
dagger(x::Symbolic{AbstractOperator}) = SDagger{AbstractOperator}(x)
dagger(x::SScaledKet) = SScaledBra(conj(x.coeff), dagger(x.obj))
dagger(x::SAdd) = (+)((dagger(i) for i in arguments(x))...)
dagger(x::SScaledBra) = SScaledKet(conj(x.coeff), dagger(x.obj))
dagger(x::SZeroOperator) = x
dagger(x::SHermitianOperator) = x
dagger(x::SHermitianUnitaryOperator) = x
dagger(x::SUnitaryOperator) = inv(x)
dagger(x::STensorBra) = STensorKet(collect(dagger(i) for i in x.terms))
dagger(x::STensorKet) = STensorBra(collect(dagger(i) for i in x.terms))
dagger(x::STensorOperator) = STensorOperator(collect(dagger(i) for i in x.terms))
dagger(x::SScaledOperator) = SScaledOperator(conj(x.coeff), dagger(x.obj))
dagger(x::SApplyKet) = dagger(x.ket)*dagger(x.op)
dagger(x::SApplyBra) = dagger(x.op)*dagger(x.bra)
dagger(x::SMulOperator) = SMulOperator(collect(dagger(i) for i in reverse(x.terms)))
dagger(x::SBraKet) = SBraKet(dagger(x.ket), dagger(x.bra))
dagger(x::SOuterKetBra) = SOuterKetBra(dagger(x.bra), dagger(x.ket))
dagger(x::SDagger) = x.obj
basis(x::SDagger) = basis(x.obj)
function Base.show(io::IO, x::SDagger)
    print(io,x.obj)
    print(io,"†")
end

"""Trace of an operator

```jldoctest
julia> @op A; @op B;

julia> tr(A)
tr(A)

julia> tr(A⊗B)
tr(A)*tr(B)

julia> tr(commutator(A, B))
0

julia> @bra b; @ket k;

julia> tr(k*b)
⟨b||k⟩
```
"""
@withmetadata struct STrace <: Symbolic{Complex}
    op::Symbolic{AbstractOperator}
end
isexpr(::STrace) = true
iscall(::STrace) = true
arguments(x::STrace) = [x.op]
sorted_arguments(x::STrace) = arguments(x)
operation(x::STrace) = tr
head(x::STrace) = :tr
children(x::STrace) = [:tr, x.op]
Base.show(io::IO, x::STrace) = print(io, "tr($(x.op))")
tr(x::Symbolic{AbstractOperator}) = STrace(x)
tr(x::SScaled{AbstractOperator}) = x.coeff*tr(x.obj)
tr(x::SAdd{AbstractOperator}) = (+)((tr(i) for i in arguments(x))...)
tr(x::SOuterKetBra) = x.bra*x.ket
tr(x::SCommutator) = 0
tr(x::STensorOperator) = (*)((tr(i) for i in arguments(x))...)
Base.hash(x::STrace, h::UInt) = hash((head(x), arguments(x)), h)
Base.isequal(x::STrace, y::STrace) = isequal(x.op, y.op)

"""Partial trace over system i of a composite quantum system

```jldoctest
julia> @op A; @op B;

julia> ptrace(A, 1)
tr1(A)

julia> ptrace(A⊗B, 1)
(tr(A))B

julia> @ket k; @bra b;

julia> pure_state = A ⊗ (k*b)
(A⊗|k⟩⟨b|)

julia> ptrace(pure_state, 1)
(tr(A))|k⟩⟨b|

julia> ptrace(pure_state, 2)
(⟨b||k⟩)A

julia> mixed_state = (A⊗(k*b)) + ((k*b)⊗B)
((A⊗|k⟩⟨b|)+(|k⟩⟨b|⊗B))

julia> ptrace(mixed_state, 1)
((0 + ⟨b||k⟩)B+(tr(A))|k⟩⟨b|)

julia> ptrace(mixed_state, 2)
((0 + ⟨b||k⟩)A+(tr(B))|k⟩⟨b|)
```
"""
@withmetadata struct SPartialTrace <: Symbolic{Complex}
    obj
    sys::Int
end
isexpr(::SPartialTrace) = true
iscall(::SPartialTrace) = true
arguments(x::SPartialTrace) = [x.obj, x.sys]
operation(x::SPartialTrace) = ptrace
head(x::SPartialTrace) = :ptrace
children(x::SPartialTrace) = [:ptrace, x.obj, x.sys]
Base.show(io::IO, x::SPartialTrace) = print(io, "tr$(x.sys)($(x.obj))")
ptrace(x::Symbolic{AbstractOperator}, s) = SPartialTrace(x, s)
function ptrace(x::STensorOperator, s)
    terms = arguments(x)
    sys_op = terms[s]
    new_terms = deleteat!(copy(terms), s)
    isone(length(new_terms)) ? tr(sys_op)*first(new_terms) : tr(sys_op)*STensorOperator(new_terms)
end
function ptrace(x::SAddOperator, s)
    terms = arguments(x)
    add_terms = []
    for i in terms
        if isexpr(i) && operation(i) === ⊗
            isa(i, SScaledOperator) ? prod_terms = arguments(i.obj) : prod_terms = arguments(i)
            sys_op = prod_terms[s]
            new_terms = deleteat!(copy(prod_terms), s)
            isone(length(new_terms)) ? push!(add_terms, tr(sys_op)*first(new_terms)) : push!(add_terms, tr(sys_op)*STensorOperator(new_terms))
        else
            throw(ArgumentError("cannot take partial trace of a single quantum system"))
        end
    end
    (+)(add_terms...)
end

"""Inverse Operator

```jldoctest
julia> @op A;

julia> inv(A)
A⁻¹

julia> inv(A)*A
𝕀
```
"""
@withmetadata struct SInvOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SInvOperator) = true
iscall(::SInvOperator) = true
arguments(x::SInvOperator) = [x.op]
operation(x::SInvOperator) = inv
head(x::SInvOperator) = :inv
children(x::SInvOperator) = [:inv, x.op]
basis(x::SInvOperator) = basis(x.op)
Base.show(io::IO, x::SInvOperator) = print(io, "$(x.op)⁻¹")
Base.:(*)(invop::SInvOperator, op::SOperator) = isequal(invop.op, op) ? IdentityOp(basis(op)) : SMulOperator(invop, op)
Base.:(*)(op::SOperator, invop::SInvOperator) = isequal(op, invop.op) ? IdentityOp(basis(op)) : SMulOperator(op, invop)
inv(x::Symbolic{AbstractOperator}) = SInvOperator(x)

"""Completely depolarized state

```jldoctest
julia> MixedState(X1⊗X2)
𝕄

julia> express(MixedState(X1⊗X2))
Operator(dim=4x4)
  basis: [Spin(1/2) ⊗ Spin(1/2)]sparse([1, 2, 3, 4], [1, 2, 3, 4], ComplexF64[0.25 + 0.0im, 0.25 + 0.0im, 0.25 + 0.0im, 0.25 + 0.0im], 4, 4)

julia> express(MixedState(X1⊗X2), CliffordRepr())
𝒟ℯ𝓈𝓉𝒶𝒷

𝒳ₗ━━
+ X_
+ _X
𝒮𝓉𝒶𝒷

𝒵ₗ━━
+ Z_
+ _Z
```"""
@withmetadata struct MixedState <: Symbolic{AbstractOperator}
    basis::Basis # From QuantumOpticsBase # TODO make QuantumInterface
end
MixedState(x::Symbolic{AbstractKet}) = MixedState(basis(x))
MixedState(x::Symbolic{AbstractOperator}) = MixedState(basis(x))
isexpr(::MixedState) = false
basis(x::MixedState) = x.basis
symbollabel(x::MixedState) = "𝕄"

"""The identity operator for a given basis

```judoctest
julia> IdentityOp(X1⊗X2)
𝕀

julia> express(IdentityOp(Z2))
Operator(dim=2x2)
  basis: Spin(1/2)sparse([1, 2], [1, 2], ComplexF64[1.0 + 0.0im, 1.0 + 0.0im], 2, 2)
```"""
@withmetadata struct IdentityOp <: Symbolic{AbstractOperator}
    basis::Basis # From QuantumOpticsBase # TODO make QuantumInterface
end
IdentityOp(x::Symbolic{AbstractKet}) = IdentityOp(basis(x))
IdentityOp(x::Symbolic{AbstractOperator}) = IdentityOp(basis(x))
isexpr(::IdentityOp) = false
basis(x::IdentityOp) = x.basis
symbollabel(x::IdentityOp) = "𝕀"
ishermitian(::IdentityOp) = true
isunitary(::IdentityOp) = true

"""Identity operator in qubit basis"""
const I = IdentityOp(qubit_basis)   