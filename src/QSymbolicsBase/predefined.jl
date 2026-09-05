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
"""
    X1

Basis state of σˣ
"""
const X1 = const X₁ = const Lp = const L₊ = XBasisState(1, qubit_basis)
"""
    X2

Basis state of σˣ
"""
const X2 = const X₂ = const Lm = const L₋ = XBasisState(2, qubit_basis)
"""
    Y1

Basis state of σʸ
"""
const Y1 = const Y₁ = const Lpi = const L₊ᵢ = YBasisState(1, qubit_basis)
"""
    Y2

Basis state of σʸ
"""
const Y2 = const Y₂ = const Lmi = const L₋ᵢ = YBasisState(2, qubit_basis)
"""
    Z1

Basis state of σᶻ
"""
const Z1 = const Z₁ = const L0 = const L₀ = ZBasisState(1, qubit_basis)
"""
    Z2

Basis state of σᶻ
"""
const Z2 = const Z₂ = const L1 = const L₁ = ZBasisState(2, qubit_basis)

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
eigvals(g::XGate) = [1,-1]
symbollabel(::XGate) = "X"
ishermitian(::XGate) = true
isunitary(::XGate) = true

@withmetadata struct YGate <: AbstractSingleQubitGate end
eigvecs(g::YGate) = [Y1,Y2]
eigvals(g::YGate) = [1,-1]
symbollabel(::YGate) = "Y"
ishermitian(::YGate) = true
isunitary(::YGate) = true

@withmetadata struct ZGate <: AbstractSingleQubitGate end
eigvecs(g::ZGate) = [Z1,Z2]
eigvals(g::ZGate) = [1,-1]
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

"""
    X

Pauli X operator, also available as the constant `σˣ`
"""
const X = const σˣ = XGate()
"""
    Y

Pauli Y operator, also available as the constant `σʸ`
"""
const Y = const σʸ = YGate()
"""
    Z

Pauli Z operator, also available as the constant `σᶻ`
"""
const Z = const σᶻ = ZGate()
"""
    Pm

Pauli "minus" operator, also available as the constant `σ₋`
"""
const Pm = const σ₋ = PauliM()
"""
    Pp

Pauli "plus" operator, also available as the constant `σ₊`
"""
const Pp = const σ₊ = PauliP()
"""
    H

Hadamard gate
"""
const H = HGate()
"""
    CNOT

CNOT gate
"""
const CNOT = CNOTGate()
"""
    CPHASE

CPHASE gate
"""
const CPHASE = CPHASEGate()

##
# Other special or useful objects
##

"""
$TYPEDEF

Completely depolarized state

```jldoctest
julia> MixedState(X1⊗X2)
𝕄

julia> express(MixedState(X1⊗X2))
Operator(dim=4x4)
  basis: [Spin(1/2) ⊗ Spin(1/2)]
 0.25 + 0.0im        ⋅             ⋅             ⋅     
       ⋅       0.25 + 0.0im        ⋅             ⋅
       ⋅             ⋅       0.25 + 0.0im        ⋅
       ⋅             ⋅             ⋅       0.25 + 0.0im

julia> express(MixedState(X1⊗X2), CliffordRepr())
𝒟ℯ𝓈𝓉𝒶𝒷
 
𝒳ₗ━━
+ X_
+ _X
𝒮𝓉𝒶𝒷
 
𝒵ₗ━━
+ Z_
+ _Z
```
"""
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
```
"""
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
