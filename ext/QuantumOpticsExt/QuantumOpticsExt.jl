module QuantumOpticsExt

using QuantumInterface, QuantumOpticsBase
using QuantumInterface: samebases
using QuantumSymbolics
using QuantumSymbolics:
    HGate, XGate, YGate, ZGate, CPHASEGate, CNOTGate, PauliP, PauliM,
    XCXGate, XCYGate, XCZGate, YCXGate, YCYGate, YCZGate, ZCXGate, ZCYGate, ZCZGate,
    XBasisState, YBasisState, ZBasisState,
    NumberOp, CreateOp, DestroyOp,
    FockState,
    MixedState, IdentityOp,
    qubit_basis,
    SAddOperator, SScaledOperator, SMulOperator, STensorOperator,
    SCommutator, SAnticommutator
import QuantumSymbolics: express, express_nolookup
using TermInterface
using TermInterface: isexpr, head, operation, arguments, metadata

const _b2 = SpinBasis(1//2)
const _l0 = spinup(_b2)
const _l1 = spindown(_b2)
const _s₊ = (_l0+_l1)/√2
const _s₋ = (_l0-_l1)/√2
const _i₊ = (_l0+im*_l1)/√2
const _i₋ = (_l0-im*_l1)/√2
const _σ₊ = sigmap(_b2)
const _σ₋ = sigmam(_b2)
const _l00 = projector(_l0)
const _l11 = projector(_l1)
const _id = identityoperator(_b2)
const _z = sigmaz(_b2)
const _x = sigmax(_b2)
const _y = sigmay(_b2)
const _hadamard = (sigmaz(_b2)+sigmax(_b2))/√2
const _cnot = _l00⊗_id + _l11⊗_x
const _cphase = _l00⊗_id + _l11⊗_z
const _phase = _l00 + im*_l11
const _iphase = _l00 - im*_l11

const _bf2 = FockBasis(2)
const _f0₂ = fockstate(_bf2, 0)
const _f1₂ = fockstate(_bf2, 1)
const _ad₂ = create(_bf2)
const _a₂ = destroy(_bf2)
const _n₂ = number(_bf2)

express_nolookup(::HGate, ::QuantumOpticsRepr) = _hadamard
express_nolookup(::XGate, ::QuantumOpticsRepr) = _x
express_nolookup(::YGate, ::QuantumOpticsRepr) = _y
express_nolookup(::ZGate, ::QuantumOpticsRepr) = _z
express_nolookup(::CPHASEGate, ::QuantumOpticsRepr) = _cphase
express_nolookup(::CNOTGate, ::QuantumOpticsRepr) = _cnot

const xyzopdict = Dict(:X=>_x, :Y=>_y, :Z=>_z)
const xyzstatedict = Dict(:X=>(_s₊,_s₋),:Y=>(_i₊,_i₋),:Z=>(_l0,_l1))
for control in (:X, :Y, :Z)
    for target in (:X, :Y, :Z)
        k1, k2 = xyzstatedict[control]
        o = xyzopdict[target]
        gate = projector(k1)⊗_id + projector(k2)⊗o
        structname = Symbol(control,"C",target,"Gate")
        let gate=copy(gate)
            @eval express_nolookup(::$(structname), ::QuantumOpticsRepr) = $gate
        end
    end
end

express_nolookup(::PauliM, ::QuantumOpticsRepr) = _σ₋
express_nolookup(::PauliP, ::QuantumOpticsRepr) = _σ₊

express_nolookup(s::XBasisState, ::QuantumOpticsRepr) = (_s₊,_s₋)[s.idx]
express_nolookup(s::YBasisState, ::QuantumOpticsRepr) = (_i₊,_i₋)[s.idx]
express_nolookup(s::ZBasisState, ::QuantumOpticsRepr) = (_l0,_l1)[s.idx]

function finite_basis(s,r)
    if isfinite(length(basis(s)))
        return basis(s)
    else
        if isa(basis(s), FockBasis)
            return FockBasis(r.cutoff)
        else
            error()
        end
    end
end
express_nolookup(s::FockState, r::QuantumOpticsRepr) = fockstate(finite_basis(s,r),s.idx)
express_nolookup(s::CoherentState, r::QuantumOpticsRepr) = coherentstate(finite_basis(s,r),s.alpha)
express_nolookup(s::SqueezedState, r::QuantumOpticsRepr) = (b = finite_basis(s,r); squeeze(b, s.z)*fockstate(b, 0))
express_nolookup(o::NumberOp, r::QuantumOpticsRepr) = number(finite_basis(o,r))
express_nolookup(o::CreateOp, r::QuantumOpticsRepr) = create(finite_basis(o,r))
express_nolookup(o::DestroyOp, r::QuantumOpticsRepr) = destroy(finite_basis(o,r))
express_nolookup(o::DisplaceOp, r::QuantumOpticsRepr) = displace(finite_basis(o,r), o.alpha)
express_nolookup(o::SqueezeOp, r::QuantumOpticsRepr) = squeeze(finite_basis(o,r), o.z)
express_nolookup(x::MixedState, r::QuantumOpticsRepr) = identityoperator(finite_basis(x,r))/length(finite_basis(x,r)) # TODO there is probably a more efficient way to represent it
express_nolookup(x::IdentityOp, r::QuantumOpticsRepr) = identityoperator(finite_basis(x,r))

include("gaussian.jl")

express_nolookup(p::PauliNoiseCPTP, ::QuantumOpticsRepr) = LazySuperSum(SpinBasis(1//2), [1-p.px-p.py-p.pz,p.px,p.py,p.pz],
                                                               [LazyPrePost(_id,_id),LazyPrePost(_x,_x),LazyPrePost(_y,_y),LazyPrePost(_z,_z)])

express_nolookup(s::SOuterKetBra, r::QuantumOpticsRepr) = projector(express(s.ket, r), express(s.bra, r))

include("should_upstream.jl")

##
# Lazy express methods for QuantumOpticsRepr(lazy=true)
#
# When lazy=true, composite operator expressions (sums, products, tensor products)
# are expressed using LazySum, LazyProduct, and LazyTensor instead of eager dense
# operators. Individual (leaf) operators are still expressed eagerly.
##

# Symbolic operator addition → LazySum
function express_nolookup(x::SAddOperator, r::QuantumOpticsRepr)
    r.lazy || return +(express.(arguments(x), (r,))...)
    factors = ComplexF64[]
    ops = []
    for a in arguments(x)
        if a isa SScaledOperator
            push!(factors, ComplexF64(a.coeff))
            push!(ops, express(a.obj, r))
        else
            push!(factors, one(ComplexF64))
            push!(ops, express(a, r))
        end
    end
    LazySum(factors, ops)
end

# Symbolic operator multiplication → LazyProduct
function express_nolookup(x::SMulOperator, r::QuantumOpticsRepr)
    r.lazy || return *(express.(arguments(x), (r,))...)
    expressed = Tuple(express.(arguments(x), (r,)))
    LazyProduct(expressed)
end

# Symbolic tensor product of operators → LazyTensor
function express_nolookup(x::STensorOperator, r::QuantumOpticsRepr)
    r.lazy || return ⊗(express.(arguments(x), (r,))...)
    args = arguments(x)
    expressed = [express(t, r) for t in args]
    bl = tensor([op.basis_l for op in expressed]...)
    br = tensor([op.basis_r for op in expressed]...)
    # Only include non-identity subsystems for efficient LazyTensor
    indices = Int[]
    nontrivial = []
    for (i, (sym_arg, num_op)) in enumerate(zip(args, expressed))
        if !(sym_arg isa IdentityOp)
            push!(indices, i)
            push!(nontrivial, num_op)
        end
    end
    if isempty(nontrivial)
        return identityoperator(bl)
    end
    LazyTensor(bl, br, indices, Tuple(nontrivial))
end

# Symbolic commutator [A, B] = AB - BA → LazySum of LazyProducts
function express_nolookup(x::SCommutator, r::QuantumOpticsRepr)
    r.lazy || return commutator(express(x.op1, r), express(x.op2, r))
    a = express(x.op1, r)
    b = express(x.op2, r)
    LazySum([one(ComplexF64), -one(ComplexF64)],
            [LazyProduct(a, b), LazyProduct(b, a)])
end

# Symbolic anticommutator {A, B} = AB + BA → LazySum of LazyProducts
function express_nolookup(x::SAnticommutator, r::QuantumOpticsRepr)
    r.lazy || return anticommutator(express(x.op1, r), express(x.op2, r))
    a = express(x.op1, r)
    b = express(x.op2, r)
    LazySum([one(ComplexF64), one(ComplexF64)],
            [LazyProduct(a, b), LazyProduct(b, a)])
end

end
