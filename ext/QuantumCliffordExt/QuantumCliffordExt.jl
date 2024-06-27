module QuantumCliffordExt

using QuantumInterface
using QuantumInterface: AbstractKet, AbstractOperator, CompositeBasis
using QuantumSymbolics
using QuantumSymbolics: HGate, XGate, YGate, ZGate, CPHASEGate, CNOTGate,
    XBasisState, YBasisState, ZBasisState, MixedState, IdentityOp,
    XCXGate, XCYGate, XCZGate, YCXGate, YCYGate, YCZGate, ZCXGate, ZCYGate, ZCZGate,
    Symbolic
import QuantumSymbolics: express, express_nolookup, express_from_cache
using TermInterface
using TermInterface: isexpr, head, operation, arguments, metadata

using QuantumClifford

const _qc_l = MixedDestabilizer(S"Z")
const _qc_h = MixedDestabilizer(S"-Z")
const _qc_s₊ = MixedDestabilizer(S"X")
const _qc_s₋ = MixedDestabilizer(S"-X")
const _qc_i₊ = MixedDestabilizer(S"Y")
const _qc_i₋ = MixedDestabilizer(S"-Y")

express_nolookup(s::XBasisState, ::CliffordRepr) = (_qc_s₊,_qc_s₋)[s.idx]
express_nolookup(s::YBasisState, ::CliffordRepr) = (_qc_i₊,_qc_i₋)[s.idx]
express_nolookup(s::ZBasisState, ::CliffordRepr) = (_qc_l,_qc_h)[s.idx]
function express_nolookup(s::Symbolic{T}, repr::CliffordRepr) where {T<:Union{AbstractKet,AbstractOperator}}
    if isexpr(s) && operation(s)==⊗
        #operation(s)(express.(arguments(s), (repr,))...) # TODO this does not work because QuantumClifford.⊗ is different from ⊗
        QuantumClifford.tensor(express.(arguments(s), (repr,))...)
    else
        error("Encountered an object $(s) of type $(typeof(s)) that can not be converted to $(repr) representation") # TODO make a nice error type
    end
end

express_nolookup(::CPHASEGate,       ::CliffordRepr, ::UseAsOperation) = QuantumClifford.sCPHASE
express_nolookup(::CNOTGate,         ::CliffordRepr, ::UseAsOperation) = QuantumClifford.sCNOT

for control in (:X, :Y, :Z)
    for target in (:X, :Y, :Z)
        structname = Symbol(control,"C",target,"Gate")
        qcname = Symbol("s",control,"C",target)
        defexpress = :(express_nolookup(::$(structname), ::CliffordRepr, ::UseAsOperation) = $(qcname))
        eval(defexpress)
    end
end

express_nolookup(::XGate,            ::CliffordRepr, ::UseAsOperation) = QuantumClifford.sX
express_nolookup(::YGate,            ::CliffordRepr, ::UseAsOperation) = QuantumClifford.sY
express_nolookup(::ZGate,            ::CliffordRepr, ::UseAsOperation) = QuantumClifford.sZ
express_nolookup(x::STensorOperator,  r::CliffordRepr, u::UseAsOperation) = QCGateSequence([express(t,r,u) for t in x.terms])

express_nolookup(op::QuantumClifford.PauliOperator, ::CliffordRepr, ::UseAsObservable) = op
express_nolookup(op::STensorOperator, r::CliffordRepr, u::UseAsObservable) = QuantumClifford.tensor(express.(arguments(op),(r,),(u,))...)
express_nolookup(::XGate, ::CliffordRepr, ::UseAsObservable) = QuantumClifford.P"X"
express_nolookup(::YGate, ::CliffordRepr, ::UseAsObservable) = QuantumClifford.P"Y"
express_nolookup(::ZGate, ::CliffordRepr, ::UseAsObservable) = QuantumClifford.P"Z"
express_nolookup(op::SScaledOperator, r::CliffordRepr, u::UseAsObservable) = arguments(op)[1] * express(arguments(op)[2],r,u)
express_nolookup(x::SMulOperator,     r::CliffordRepr, u::UseAsObservable) = (*)((express(t,r,u) for t in arguments(x))...)
express_nolookup(x::STensorOperator,  r::CliffordRepr, u::UseAsObservable) = QuantumClifford.tensor((express(t,r,u) for t in arguments(x))...)
express_nolookup(op, ::CliffordRepr, ::UseAsObservable) = error("Can not convert $(op) into a `PauliOperator`, which is the only observable that can be computed for QuantumClifford objects. Consider defining `express_nolookup(op, ::CliffordRepr, ::UseAsObservable)::PauliOperator` for this object.")

struct QCRandomSampler # TODO specify types
    operators # union of QCRandomSampler and MixedDestabilizer
    weights
end
function express_nolookup(x::SAddOperator, repr::CliffordRepr)
    weights = collect(values(x.dict))
    symops = collect(keys(x.dict))
    # TODO assert norms of operators are all ==1
    @assert sum(weights) ≈ 1.0
    ops = express_nolookup.(symops, (repr,))
    QCRandomSampler(ops, weights)
end
function express_from_cache(x::QCRandomSampler)
    threshold = rand()
    cweights = cumsum(x.weights)
    i = findfirst(>=(threshold), cweights) # TODO make alloc free
    express_from_cache(x.operators[i])
end
function express_nolookup(x::MixedState, ::CliffordRepr)
    nqubits = isa(x.basis, CompositeBasis) ? length(x.basis.bases) : 1
    # TODO assert all are qubits
    one(MixedDestabilizer,0,nqubits)
end
express_nolookup(x::SProjector, repr::CliffordRepr) = express_nolookup(x.ket, repr)

end
