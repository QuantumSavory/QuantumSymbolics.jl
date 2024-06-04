"""This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are homogeneous in their arguments."""

struct SKet <: Symbolic{AbstractKet}
    name::Symbol
    basis::Basis
end
struct SBra <: Symbolic{AbstractBra}
    name::Symbol
    basis::Basis
end
struct SOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
const SymQ = Union{SKet, SBra, SOperator}
istree(::SymQ) = false
metadata(::SymQ) = nothing
basis(x::SymQ) = x.basis

symbollabel(x::SymQ) = x.name
Base.show(io::IO, x::SKet) = print(io, "|$(symbollabel(x))⟩")
Base.show(io::IO, x::SBra) = print(io, "⟨$(symbollabel(x))|")
Base.show(io::IO, x::SOperator) = print(io, "$(symbollabel(x))")
Base.show(io::IO, x::SymQObj) = print(io, symbollabel(x)) # fallback that probably is not great

"""Scaling of a quantum object (ket, operator, or bra) by a number."""
@withmetadata struct SScaled{T<:QObj} <: Symbolic{T}
    coeff
    obj
    SScaled{S}(c,k) where S = _isone(c) ? k : new{S}(c,k)
end
istree(::SScaled) = true
arguments(x::SScaled) = [x.coeff, x.obj]
operation(x::SScaled) = *
exprhead(x::SScaled) = :*
Base.:(*)(c, x::Symbolic{T}) where {T<:QObj} = SScaled{T}(c,x)
Base.:(*)(x::Symbolic{T}, c) where {T<:QObj} = SScaled{T}(c,x)
Base.:(/)(x::Symbolic{T}, c) where {T<:QObj} = SScaled{T}(1/c,x)
basis(x::SScaled) = basis(x.obj)

const SScaledKet = SScaled{AbstractKet}
function Base.show(io::IO, x::SScaledKet)
    if x.coeff isa Number
        print(io, "$(x.coeff)$(x.obj)")
    else
        print(io, "($(x.coeff))$(x.obj)")
    end
end
const SScaledOperator = SScaled{AbstractOperator}
function Base.show(io::IO, x::SScaledOperator)
    if x.coeff isa Number
        print(io, "$(x.coeff)$(x.obj)")
    else
        print(io, "($(x.coeff))$(x.obj)")
    end
end
const SScaledBra = SScaled{AbstractBra}
function Base.show(io::IO, x::SScaledBra)
    if x.coeff isa Number
        print(io, "$(x.coeff)$(x.obj)")
    else
        print(io, "($(x.coeff))$(x.obj)")
    end
end

"""Addition of quantum objects (kets, operators, or bras)."""
@withmetadata struct SAdd{T<:QObj} <: Symbolic{T}
    dict
    SAdd{S}(d) where S = length(d)==1 ? SScaled{S}(reverse(first(d))...) : new{S}(d)
end
istree(::SAdd) = true
arguments(x::SAdd) = [SScaledKet(v,k) for (k,v) in pairs(x.dict)]
operation(x::SAdd) = +
exprhead(x::SAdd) = :+
Base.:(+)(xs::Vararg{Symbolic{T},N}) where {T<:QObj,N} = SAdd{T}(countmap_flatten(xs, SScaled{T}))
Base.:(+)(xs::Vararg{Symbolic{<:QObj},0}) = 0 # to avoid undefined type parameters issue in the above method
basis(x::SAdd) = basis(first(x.dict).first)

const SAddKet = SAdd{AbstractKet}
Base.show(io::IO, x::SAddKet) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddOperator = SAdd{AbstractOperator}
Base.show(io::IO, x::SAddOperator) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddBra = SAdd{AbstractBra}
Base.show(io::IO, x::SAddBra) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference

@withmetadata struct SApplyOp <: Symbolic{AbstractOperator}
    op1
    op2
    function SApplyOp(o1, o2)
        coeff, cleanterms = prefactorscalings([o1 o2])
        coeff*new(cleanterms...)
    end
end
istree(::SApplyOp) = true
arguments(x::SApplyOp) = [x.op1,x.op2]
operation(x::SApplyOp) = *
exprhead(x::SApplyOp) = :*
Base.:(*)(op1::Symbolic{AbstractOperator}, op2::Symbolic{AbstractOperator}) = SApplyOp(op1,op2)
Base.show(io::IO, x::SApplyOp) = begin print(io, x.op1); print(io, x.op2) end
basis(x::SApplyOp) = basis(x.op1)

"""Tensor product of quantum objects (kets, operators, or bras)."""
@withmetadata struct STensor{T<:QObj} <: Symbolic{T}
    terms
    function STensor{S}(terms) where S
        coeff, cleanterms = prefactorscalings(terms)
        coeff * new{S}(cleanterms)
    end
end
istree(::STensor) = true
arguments(x::STensor) = x.terms
operation(x::STensor) = ⊗
exprhead(x::STensor) = :⊗
⊗(xs::Symbolic{T}...) where {T<:QObj} = STensor{T}(collect(xs))
basis(x::STensor) = tensor(basis.(x.terms)...)

const STensorKet = STensor{AbstractKet}
Base.show(io::IO, x::STensorKet) = print(io, join(map(string, arguments(x)),""))
const STensorOperator = STensor{AbstractOperator}
Base.show(io::IO, x::STensorOperator) = print(io, join(map(string, arguments(x)),"⊗"))
const STensorSuperOperator = STensor{AbstractSuperOperator}
Base.show(io::IO, x::STensorSuperOperator) = print(io, join(map(string, arguments(x)),"⊗"))
const STensorBra = STensor{AbstractBra}
Base.show(io::IO, x::STensorBra) = print(io, join(map(string, arguments(x)),""))

"""Symbolic commutator of two operators"""
@withmetadata struct SCommutator <: Symbolic{AbstractOperator}
    op1
    op2
    function SCommutator(o1, o2) 
        coeff, cleanterms = prefactorscalings([o1 o2])
        cleanterms[1] === cleanterms[2] ? 0 : coeff*new(cleanterms...)
    end
end
istree(::SCommutator) = true
arguments(x::SCommutator) = [x.op1, x.op2]
commutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator}) = SCommutator(o1, o2)
Base.show(io::IO, x::SCommutator) = print(io, "[$(x.op1),$(x.op2)]")
basis(x::SCommutator) = basis(x.op1)
expand(x::SCommutator) = x == 0 ? x : (x.op1)*(x.op2) - (x.op2)*(x.op1)  # expands commutator into [A,B] = AB - BA

"""Symbolic anticommutator of two operators"""
@withmetadata struct SAnticommutator <: Symbolic{AbstractOperator}
    op1
    op2
    function SAnticommutator(o1, o2) 
        coeff, cleanterms = prefactorscalings([o1 o2])
        cleanterms[1] === cleanterms[2] && coeff === -1 ? 0 : coeff*new(cleanterms...)
    end
end
istree(::SAnticommutator) = true
arguments(x::SAnticommutator) = [x.op1, x.op2]
anticommutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator}) = SAnticommutator(o1, o2)
Base.show(io::IO, x::SAnticommutator) = print(io, "{$(x.op1),$(x.op2)}")
basis(x::SAnticommutator) = basis(x.op1)
expand(x::SAnticommutator) = x == 0 ? x : (x.op1)*(x.op2) + (x.op2)*(x.op1)  # expands anticommutator into {A,B} = AB + BA

"""Expanding commutator and anticommutator expression"""

