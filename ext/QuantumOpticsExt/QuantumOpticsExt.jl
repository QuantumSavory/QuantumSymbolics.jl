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
    SAddOperator, SMulOperator, STensorOperator, SCommutator, SAnticommutator,
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

##
# Lazy QuantumOptics output, opt-in via `QuantumOpticsRepr(lazy=true)`.
#
# The translation follows how structured operators are assembled natively in
# QuantumOptics.jl: a sum of local tensor terms becomes a `LazySum` of `LazyTensor`s, an
# operator product becomes a `LazyProduct`, and a (anti)commutator becomes a lazy sum of
# products. A `LazyTensor` records only the non-trivial factors and leaves identities on the
# remaining subsystems implicit, so the locality of each term survives the conversion instead
# of being flattened into a dense matrix. With `lazy` unset, every method reproduces the
# eager generic conversion verbatim, so the default behaviour is untouched.
#
# Scalar prefactors are handled for free: `prefactorscalings` lifts them out of products and
# tensors at the symbolic level, and the generic fallback then multiplies the resulting lazy
# operator by the number (`LazySum`, `LazyProduct`, and `LazyTensor` each support that).
#
# `lazy` is read through `hasproperty` so the extension still loads, and stays eager, against
# QuantumInterface releases that predate the field.
##

_islazy(r::QuantumOpticsRepr) = hasproperty(r, :lazy) && r.lazy

function express_nolookup(s::SAddOperator, r::QuantumOpticsRepr)
    _islazy(r) || return operation(s)(express.(arguments(s), (r,))...)
    summands = collect(s.dict) # `obj => coefficient` pairs
    LazySum([coeff for (_, coeff) in summands], [express(obj, r) for (obj, _) in summands])
end

function express_nolookup(s::SMulOperator, r::QuantumOpticsRepr)
    _islazy(r) || return operation(s)(express.(arguments(s), (r,))...)
    LazyProduct(express.(arguments(s), (r,))...)
end

function express_nolookup(s::STensorOperator, r::QuantumOpticsRepr)
    _islazy(r) || return operation(s)(express.(arguments(s), (r,))...)
    factors = arguments(s)
    ops = express.(factors, (r,))
    # A `LazyTensor` factor must live on a single subsystem of the composite basis. A factor
    # that is itself multipartite (e.g. an expressed two-qubit gate) cannot be placed, so we
    # keep the eager tensor product for that term.
    any(o -> o.basis_l isa CompositeBasis || o.basis_r isa CompositeBasis, ops) && return ⊗(ops...)
    bl = tensor((o.basis_l for o in ops)...)
    br = tensor((o.basis_r for o in ops)...)
    # Store only the non-identity factors; `LazyTensor` fills the omitted subsystems with
    # identities, which is the structure-preserving point of the lazy backend. Identity is
    # detected on the symbolic `IdentityOp` factor, avoiding a materialized comparison.
    active = [i for (i, f) in enumerate(factors) if !(f isa IdentityOp)]
    isempty(active) && return identityoperator(bl)
    LazyTensor(bl, br, active, (ops[active]...,))
end

function express_nolookup(s::SCommutator, r::QuantumOpticsRepr)
    _islazy(r) || return operation(s)(express.(arguments(s), (r,))...)
    a, b = express(s.op1, r), express(s.op2, r)
    LazySum([1, -1], [LazyProduct(a, b), LazyProduct(b, a)])
end

function express_nolookup(s::SAnticommutator, r::QuantumOpticsRepr)
    _islazy(r) || return operation(s)(express.(arguments(s), (r,))...)
    a, b = express(s.op1, r), express(s.op2, r)
    LazySum([1, 1], [LazyProduct(a, b), LazyProduct(b, a)])
end

include("should_upstream.jl")

end
