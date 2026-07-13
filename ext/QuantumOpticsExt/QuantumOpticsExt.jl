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

const lazy_σ₊ = LazyPrePost(_σ₊, _σ₊)
const lazy_σ₋ = LazyPrePost(_σ₋, _σ₋)
const lazy_id = LazyPrePost(_id, _id)
const lazy_x  = LazyPrePost(_x, _x)
const lazy_y  = LazyPrePost(_y, _y)
const lazy_z  = LazyPrePost(_z, _z)
const lazy_hadamard = LazyPrePost(_hadamard, _hadamard)

const lazy_cnot   = LazyPrePost(_cnot, _cnot)
const lazy_cphase = LazyPrePost(_cphase, _cphase)
const lazy_phase  = LazyPrePost(_phase, _phase)
const lazy_iphase = LazyPrePost(_iphase, _iphase)

const lazy_a₂   = LazyPrePost(_a₂, _a₂)
const lazy_ad₂  = LazyPrePost(_ad₂, _ad₂)
const lazy_n₂   = LazyPrePost(_n₂, _n₂)

const lazy_s₊ = LazySuperSum(_b2, [1/√2, 1/√2], [_l0, _l1])
const lazy_s₋ = LazySuperSum(_b2, [1/√2, -1/√2], [_l0, _l1])
const lazy_i₊ = LazySuperSum(_b2, [1/√2, 1im/√2], [_l0, _l1])
const lazy_i₋ = LazySuperSum(_b2, [1/√2, -1im/√2], [_l0, _l1])

express_nolookup(::HGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_hadamard : _hadamard
express_nolookup(::XGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_x : _x
express_nolookup(::YGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_y : _y
express_nolookup(::ZGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_z : _z
express_nolookup(::CPHASEGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_cphase : _cphase
express_nolookup(::CNOTGate, repr::QuantumOpticsRepr) = repr.lazy ? lazy_cnot : _cnot

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

express_nolookup(::PauliM, repr::QuantumOpticsRepr) = repr.lazy ? lazy_σ₊ : _σ₋
express_nolookup(::PauliP, repr::QuantumOpticsRepr) = repr.lazy ? lazy_σ₊ : _σ₊

express_nolookup(s::XBasisState, repr::QuantumOpticsRepr) = repr.lazy ? (lazy_s₊, lazy_s₋)[s.idx] : (_s₊, _s₋)[s.idx]
express_nolookup(s::YBasisState, repr::QuantumOpticsRepr) = repr.lazy ? (lazy_i₊, lazy_i₋)[s.idx] : (_i₊, _i₋)[s.idx]
express_nolookup(s::ZBasisState, repr::QuantumOpticsRepr) = repr.lazy ? (lazy_l0, lazy_l1)[s.idx] : (_l0, _l1)[s.idx]

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
