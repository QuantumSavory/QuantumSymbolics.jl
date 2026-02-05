using Symbolics
import Symbolics: simplify
using SymbolicUtils
import SymbolicUtils: _isone
using SymbolicUtils.Rewriters
using TermInterface
import TermInterface: isexpr,head,iscall,children,operation,arguments,metadata,maketerm,sorted_arguments

"""Local abstract type replacing the removed `SymbolicUtils.Symbolic{T}`.
All QuantumSymbolics concrete types subtype this."""
abstract type Symbolic{T} end

# SymbolicUtils v4 matchers call vartype() on matched terms.
# Define a fallback so our types work with @rule pattern matching.
SymbolicUtils.vartype(::Symbolic) = SymbolicUtils.SymReal

import MacroTools
import MacroTools: namify, @capture

using LinearAlgebra
import LinearAlgebra: eigvecs,ishermitian,conj,transpose,inv,exp,vec,tr

import QuantumInterface:
    apply!,
    tensor, ⊗,
    basis,Basis,samebases,IncompatibleBases,SpinBasis,FockBasis,CompositeBasis,
    nqubits,
    projector,dagger,tr,ptrace,
    AbstractBra,AbstractKet,AbstractOperator,AbstractSuperOperator,
    express,AbstractRepresentation,AbstractUse,UseAsState,UseAsObservable,UseAsOperation,
    QuantumOpticsRepr,QuantumMCRepr,CliffordRepr,GabsRepr

export SymQObj,QObj,
       AbstractRepresentation,AbstractUse,
       QuantumOpticsRepr,QuantumMCRepr,CliffordRepr,GabsRepr,QuantumToolboxRepr,
       UseAsState,UseAsObservable,UseAsOperation,
       apply!,
       express,
       tensor,⊗,
       dagger,projector,commutator,anticommutator,conj,transpose,inv,exp,vec,tr,ptrace,
       I,X,Y,Z,σˣ,σʸ,σᶻ,Pm,Pp,σ₋,σ₊,
       H,CNOT,CPHASE,XCX,XCY,XCZ,YCX,YCY,YCZ,ZCX,ZCY,ZCZ,
       X1,X2,Y1,Y2,Z1,Z2,X₁,X₂,Y₁,Y₂,Z₁,Z₂,L0,L1,Lp,Lm,Lpi,Lmi,L₀,L₁,L₊,L₋,L₊ᵢ,L₋ᵢ,
       vac,F₀,F0,F₁,F1,inf_fock_basis,
       N,n̂,Create,âꜛ,Destroy,â,basis,SpinBasis,FockBasis,
       SBra,SKet,SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator,SSuperOperator,
       @ket,@bra,@op,@superop,
       SAdd,SAddBra,SAddKet,SAddOperator,
       SScaled,SScaledBra,SScaledOperator,SScaledKet,
       STensorBra,STensorKet,STensorOperator,
       SZeroBra,SZeroKet,SZeroOperator,
       SConjugate,STranspose,SProjector,SDagger,SInvOperator,SExpOperator,SVec,STrace,SPartialTrace,
       MixedState,IdentityOp,
       SApplyKet,SApplyBra,SMulOperator,SSuperOpApply,SCommutator,SAnticommutator,SBraKet,SOuterKetBra,
       HGate,XGate,YGate,ZGate,CPHASEGate,CNOTGate,
       XBasisState,YBasisState,ZBasisState,FockState,CoherentState,SqueezedState,TwoSqueezedState,BosonicThermalState,
       NumberOp,CreateOp,DestroyOp,PhaseShiftOp,DisplaceOp,SqueezeOp,
       TwoSqueezeOp,BeamSplitterOp,
       XCXGate,XCYGate,XCZGate,YCXGate,YCYGate,YCZGate,ZCXGate,ZCYGate,ZCZGate,
       qsimplify,qsimplify_pauli,qsimplify_commutator,qsimplify_anticommutator,qsimplify_fock,
       qexpand,
       isunitary,
       KrausRepr,kraus




# TODO: move this to QuantumInterface
"""Representation using kets, bras, density matrices, and superoperators governed by `QuantumToolbox.jl`."""
Base.@kwdef struct QuantumToolboxRepr <: AbstractRepresentation 
    cutoff::Int = 2
end

##
# Metadata cache helpers
##

const CacheType = Dict{Tuple{<:AbstractRepresentation,<:AbstractUse},Any}
mutable struct Metadata
    express_cache::CacheType # TODO use more efficient mapping
end
Metadata() = Metadata(CacheType())

"""Decorate a struct definition in order to add a metadata dict which would be storing cached `express` results."""
macro withmetadata(strct)
    ex = quote $strct end
    if @capture(ex, (struct T_{params__} fields__ end) | (struct T_{params__} <: A_ fields__ end))
        struct_name = namify(T)
        args = (namify(i) for i in fields if !MacroTools.isexpr(i, String, :string))
        constructor = :($struct_name{S}($(args...)) where S = new{S}($((args..., :(Metadata()))...)))
    elseif @capture(ex, struct T_ fields__ end)
        struct_name = namify(T)
        args = (namify(i) for i in fields if !MacroTools.isexpr(i, String, :string))
        constructor = :($struct_name($(args...)) = new($((args..., :(Metadata()))...)))
    else @capture(ex, struct T_ end)
        struct_name = namify(T)
        constructor = :($struct_name() = new($:(Metadata())))
    end
    struct_args = strct.args[end].args
    push!(struct_args, constructor, :(metadata::Metadata))
    esc(quote
    Base.@__doc__ $strct
    metadata(x::$struct_name)=x.metadata
    end)
end

##
# Basic Types
##

const QObj = Union{AbstractBra,AbstractKet,AbstractOperator,AbstractSuperOperator}
const SymQObj = Symbolic{<:QObj} # TODO Should we use Sym or Symbolic... Sym has a lot of predefined goodies, including metadata support
Base.:(-)(x::SymQObj) = (-1)*x
Base.:(-)(x::SymQObj,y::SymQObj) = x + (-y)
Base.hash(x::SymQObj, h::UInt) = isexpr(x) ? hash((head(x), arguments(x)), h) :
hash((typeof(x),symbollabel(x),basis(x)), h)
maketerm(::Type{<:SymQObj}, f, a, m) = f(a...)

function Base.isequal(x::X,y::Y) where {X<:SymQObj, Y<:SymQObj}
    if X==Y
        if isexpr(x)
            if operation(x)==operation(y)
                ax,ay = arguments(x),arguments(y)
                (operation(x) === +) ? x._set_precomputed == y._set_precomputed : all(zip(ax,ay)) do xy isequal(xy...) end
            else
                false
            end
        else
            propsequal(x,y) # this is unholy
        end
    else
        false
    end
end
Base.isequal(::SymQObj, ::Symbolic{Complex}) = false
Base.isequal(::Symbolic{Complex}, ::SymQObj) = false

##
# Scalar symbolic arithmetic for Symbolic{Complex} types (STrace, SBraKet).
# In SymbolicUtils v3, these inherited arithmetic from Symbolic{<:Number}.
# Now we define minimal wrapper types.
##

const SymScalar = Symbolic{Complex}

"""Symbolic scaled scalar expression: `coeff * obj` where obj is a `Symbolic{Complex}`."""
struct SScaledComplex <: Symbolic{Complex}
    coeff
    obj
end
isexpr(::SScaledComplex) = true
iscall(::SScaledComplex) = true
arguments(x::SScaledComplex) = [x.coeff, x.obj]
operation(::SScaledComplex) = *
head(::SScaledComplex) = :*
children(x::SScaledComplex) = [:*, x.coeff, x.obj]
metadata(::SScaledComplex) = nothing
maketerm(::Type{SScaledComplex}, f, a, m) = f(a...)
Base.show(io::IO, x::SScaledComplex) = print(io, "($(x.coeff))$(x.obj)")
Base.hash(x::SScaledComplex, h::UInt) = hash((head(x), x.coeff, x.obj), h)
Base.isequal(x::SScaledComplex, y::SScaledComplex) = isequal(x.coeff, y.coeff) && isequal(x.obj, y.obj)

"""Symbolic sum of scalar expressions."""
struct SAddComplex <: Symbolic{Complex}
    terms
end
isexpr(::SAddComplex) = true
iscall(::SAddComplex) = true
arguments(x::SAddComplex) = x.terms
operation(::SAddComplex) = +
head(::SAddComplex) = :+
children(x::SAddComplex) = [:+; x.terms]
metadata(::SAddComplex) = nothing
maketerm(::Type{SAddComplex}, f, a, m) = f(a...)
Base.show(io::IO, x::SAddComplex) = print(io, join(map(string, x.terms), "+"))
Base.hash(x::SAddComplex, h::UInt) = hash((:+, Set(x.terms)), h)
Base.isequal(x::SAddComplex, y::SAddComplex) = Set(x.terms) == Set(y.terms)

"""Symbolic product of scalar expressions."""
struct SMulComplex <: Symbolic{Complex}
    terms
end
isexpr(::SMulComplex) = true
iscall(::SMulComplex) = true
arguments(x::SMulComplex) = x.terms
operation(::SMulComplex) = *
head(::SMulComplex) = :*
children(x::SMulComplex) = [:*; x.terms]
metadata(::SMulComplex) = nothing
maketerm(::Type{SMulComplex}, f, a, m) = f(a...)
Base.show(io::IO, x::SMulComplex) = print(io, join(map(string, x.terms), "*"))
Base.hash(x::SMulComplex, h::UInt) = hash((:*, x.terms), h)
Base.isequal(x::SMulComplex, y::SMulComplex) = isequal(x.terms, y.terms)

# Arithmetic for Symbolic{Complex}
Base.:(*)(c::Number, x::SymScalar) = iszero(c) ? 0 : (isone(c) ? x : SScaledComplex(c, x))
Base.:(*)(x::SymScalar, c::Number) = c * x
Base.:(*)(x::SymScalar, y::SymScalar) = SMulComplex([x, y])
Base.:(+)(x::SymScalar, y::SymScalar) = SAddComplex([x, y])
Base.:(+)(x::SymScalar, ys::Vararg{SymScalar}) = SAddComplex([x, ys...])
Base.:(+)(c::Number, x::SymScalar) = iszero(c) ? x : SAddComplex([c, x])
Base.:(+)(x::SymScalar, c::Number) = c + x
Base.:(-)(x::SymScalar) = (-1) * x
Base.:(-)(x::SymScalar, y::SymScalar) = x + (-y)
# SymScalar values are symbolic and never concretely zero or one
Base.iszero(::SymScalar) = false
Base.isone(::SymScalar) = false

# Allow Symbolic{Complex} as coefficient in quantum SScaled (handled by the Union dispatch in basic_ops_homogeneous.jl)

# TODO check that this does not cause incredibly bad runtime performance
# use a macro to provide specializations if that is indeed the case
propsequal(x,y) = all(n->(n==:metadata || isequal(getproperty(x,n),getproperty(y,n))), propertynames(x))


##
# Utilities
##

include("utils.jl")

##
# Most symbolic objects defined here
##

include("literal_objects.jl")
include("basic_ops_homogeneous.jl")
include("basic_ops_inhomogeneous.jl")
include("basic_superops.jl")
include("linalg.jl")
include("predefined.jl")
include("predefined_CPTP.jl")
include("predefined_fock.jl")

##
# Symbolic and simplification rules
##

include("rules.jl")

##
# Expressing in specific formalism
##

include("express.jl")

##
# Printing
##

include("latexify.jl")
