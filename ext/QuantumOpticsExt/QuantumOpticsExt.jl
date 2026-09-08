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
    qubit_basis
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

# Composite expressions (sums, products, tensor products). By default they are
# expressed eagerly by applying the symbolic operation to the expressed
# arguments. With QuantumOpticsRepr(lazy=true), produce the structure-preserving
# lazy operators (LazySum / LazyProduct / LazyTensor) instead (issue #521).
function express_nolookup(s, repr::QuantumOpticsRepr)
    isexpr(s) || error("Encountered an object $(s) of type $(typeof(s)) that can not be converted to a $(repr) representation")
    args = express.(arguments(s), (repr,))
    if repr.lazy
        op = operation(s)
        allops = all(a -> a isa AbstractOperator, args)
        if op === (+) && allops
            return LazySum(args...)
        elseif op === (*) && all(a -> a isa AbstractOperator || a isa Number, args)
            # operator product, possibly with scalar prefactors; ignore the
            # ket/bra cases (which also carry operation === *) by the guard above
            ops = Tuple(a for a in args if a isa AbstractOperator)
            factor = prod((a for a in args if a isa Number); init=1)
            if length(ops) >= 2
                return LazyProduct(ops, factor)
            elseif length(ops) == 1
                return factor * ops[1]
            end
        elseif op === (⊗) && allops
            # LazyTensor embeds one operator per subsystem; its densification
            # requires plain (densifiable) factors, so collapse any lazy factor
            # (the cheap inner operator) while keeping the tensor product itself lazy
            facs = map(a -> a isa QuantumOpticsBase.LazyOperator ? dense(a) : a, args)
            bl = tensor((a.basis_l for a in facs)...)
            br = tensor((a.basis_r for a in facs)...)
            return LazyTensor(bl, br, Tuple(eachindex(facs)), Tuple(facs))
        end
    end
    return operation(s)(args...)
end

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

end
