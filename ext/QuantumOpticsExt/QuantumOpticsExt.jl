module QuantumOpticsExt

using QuantumInterface, QuantumOpticsBase
using QuantumSymbolics
using QuantumSymbolics:
    HGate, XGate, YGate, ZGate, CPHASEGate, CNOTGate, PauliP, PauliM,
    XBasisState, YBasisState, ZBasisState,
    NumberOp, CreateOp, DestroyOp,
    FockBasisState,
    MixedState, IdentityOp,
    qubit_basis, inf_fock_basis, XCXGate, XCYGate, XCZGate, YCXGate, YCYGate, YCZGate, ZCXGate, ZCYGate, ZCZGate
import QuantumSymbolics: express, express_nolookup
using TermInterface
using TermInterface: istree, exprhead, operation, arguments, similarterm, metadata

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
const _Id = identityoperator(_b2)
const _hadamard = (sigmaz(_b2)+sigmax(_b2))/√2
const _cnot = _l00⊗_Id + _l11⊗_x
const _cphase = _l00⊗_Id + _l11⊗_z
const _phase = _l00 + im*_l11
const _iphase = _l00 - im*_l11

const _bf2 = FockBasis(2)
const _f0₂ = fockstate(_bf2, 0)
const _f1₂ = fockstate(_bf2, 1)
const _ad₂ = create(_bf2)
const _a₂ = destroy(_bf2)
const _n₂ = number(_bf2)

# New gates
# I don't know if this is right -- Alexadnru Ariton
const _xcy = _l00⊗_x + _l11⊗_y


express_nolookup(::HGate, ::QuantumOpticsRepr) = _hadamard
express_nolookup(::XGate, ::QuantumOpticsRepr) = _x
express_nolookup(::YGate, ::QuantumOpticsRepr) = _y
express_nolookup(::ZGate, ::QuantumOpticsRepr) = _z
express_nolookup(::CPHASEGate, ::QuantumOpticsRepr) = _cphase
express_nolookup(::CNOTGate, ::QuantumOpticsRepr) = _cnot
express_nolookup(::xcyGate, ::QuantumOpticsRepr) = _xcy



express_nolookup(::PauliM, ::QuantumOpticsRepr) = _σ₋
express_nolookup(::PauliP, ::QuantumOpticsRepr) = _σ₊

express_nolookup(s::XBasisState, ::QuantumOpticsRepr) = (_s₊,_s₋)[s.idx]
express_nolookup(s::YBasisState, ::QuantumOpticsRepr) = (_i₊,_i₋)[s.idx]
express_nolookup(s::ZBasisState, ::QuantumOpticsRepr) = (_l0,_l1)[s.idx]

function express_nolookup(o::FockBasisState, r::QuantumOpticsRepr)
    @warn "Fock space cutoff is not specified so we default to 2"
    @assert o.idx<2 "without a specified cutoff you can not create states higher than 1 photon"
    return (_f0₂,_f1₂)[o.idx+1]
end
function express_nolookup(o::NumberOp, r::QuantumOpticsRepr)
    @warn "Fock space cutoff is not specified so we default to 2"
    return _n₂
end
function express_nolookup(o::CreateOp, r::QuantumOpticsRepr)
    @warn "Fock space cutoff is not specified so we default to 2"
    return _ad₂
end
function express_nolookup(o::DestroyOp, r::QuantumOpticsRepr)
    @warn "Fock space cutoff is not specified so we default to 2"
    return _a₂
end

express_nolookup(x::MixedState, ::QuantumOpticsRepr) = identityoperator(basis(x))/length(basis(x)) # TODO there is probably a more efficient way to represent it
function express_nolookup(x::IdentityOp, ::QuantumOpticsRepr)
    b = basis(x)
    if b!=inf_fock_basis
        return identityoperator(basis(x)) # TODO there is probably a more efficient way to represent it
    else
        @warn "Fock space cutoff is not specified so we default to 2"
        return identityoperator(_bf2)
    end
end

express_nolookup(p::PauliNoiseCPTP, ::QuantumOpticsRepr) = LazySuperSum(SpinBasis(1//2), [1-p.px-p.py-p.pz,p.px,p.py,p.pz],
                                                               [LazyPrePost(_id,_id),LazyPrePost(_x,_x),LazyPrePost(_y,_y),LazyPrePost(_z,_z)])

include("should_upstream.jl")

end
