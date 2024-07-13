using Symbolics
import Symbolics: simplify
using SymbolicUtils
import SymbolicUtils: Symbolic,_isone,flatten_term,isnotflat,Chain,Fixpoint,Prewalk
using TermInterface
import TermInterface: isexpr,head,iscall,children,operation,arguments,metadata,maketerm
import MacroTools: namify, @capture

using LinearAlgebra
import LinearAlgebra: eigvecs,ishermitian,inv

import QuantumInterface:
    apply!,
    tensor, ⊗,
    basis,Basis,SpinBasis,FockBasis,
    nqubits,
    projector,dagger,
    AbstractBra,AbstractKet,AbstractOperator,AbstractSuperOperator

export SymQObj,QObj,
       AbstractRepresentation,AbstractUse,
       QuantumOpticsRepr,QuantumMCRepr,CliffordRepr,
       UseAsState,UseAsObservable,UseAsOperation,
       apply!,
       express,
       tensor,⊗,
       dagger,projector,commutator,anticommutator,
       I,X,Y,Z,σˣ,σʸ,σᶻ,Pm,Pp,σ₋,σ₊,
       H,CNOT,CPHASE,XCX,XCY,XCZ,YCX,YCY,YCZ,ZCX,ZCY,ZCZ,
       X1,X2,Y1,Y2,Z1,Z2,X₁,X₂,Y₁,Y₂,Z₁,Z₂,L0,L1,Lp,Lm,Lpi,Lmi,L₀,L₁,L₊,L₋,L₊ᵢ,L₋ᵢ,
       vac,F₀,F0,F₁,F1,
       N,n̂,Create,âꜛ,Destroy,â,SpinBasis,FockBasis,
       SBra,SKet,SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator,
       @ket,@bra,@op,
       SAdd,SAddBra,SAddKet,SAddOperator,
       SScaled,SScaledBra,SScaledOperator,SScaledKet,
       STensorBra,STensorKet,STensorOperator,
       SZeroBra,SZeroKet,SZeroOperator,
       SProjector,MixedState,IdentityOp,SInvOperator,
       SApplyKet,SApplyBra,SMulOperator,SSuperOpApply,SCommutator,SAnticommutator,SDagger,SBraKet,SOuterKetBra,
       HGate,XGate,YGate,ZGate,CPHASEGate,CNOTGate,
       XBasisState,YBasisState,ZBasisState,
       NumberOp,CreateOp,DestroyOp,
       XCXGate,XCYGate,XCZGate,YCXGate,YCYGate,YCZGate,ZCXGate,ZCYGate,ZCZGate,
       qsimplify,qsimplify_pauli,qsimplify_commutator,qsimplify_anticommutator,
       qexpand,
       isunitary

##
# Metadata cache helpers
##

"""An abstract type for the supported representation of quantum objects."""
abstract type AbstractRepresentation end
abstract type AbstractUse end
struct UseAsState <: AbstractUse end
struct UseAsOperation <: AbstractUse end
struct UseAsObservable <: AbstractUse end

const CacheType = Dict{Tuple{<:AbstractRepresentation,<:AbstractUse},Any}
mutable struct Metadata
    express_cache::CacheType # TODO use more efficient mapping
end
Metadata() = Metadata(CacheType())

"""Decorate a struct definition in order to add a metadata dict which would be storing cached `express` results."""
macro withmetadata(strct)
    ex = quote $strct end
    if @capture(ex, (struct T_{params__} fields__ end) | (struct T_{p1__} <: A_{p2__} fields__ end) | (struct T_{p1__} <: A_{p2__} where {p3__} fields__ end))
        struct_name = namify(T)
        args = (namify(i) for i in fields)
        constructor = :($struct_name{S}($(args...)) where S = new{S}($((args..., :(Metadata()))...)))
    elseif @capture(ex, struct T_ fields__ end)
        struct_name = namify(T)
        args = (namify(i) for i in fields)
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
maketerm(::Type{<:SymQObj}, f, a, t, m) = f(a...)

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


# TODO check that this does not cause incredibly bad runtime performance
# use a macro to provide specializations if that is indeed the case
propsequal(x,y) = all(n->isequal(getproperty(x,n),getproperty(y,n)), propertynames(x))


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
include("linalg.jl")
include("predefined.jl")
include("predefined_CPTP.jl")

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
