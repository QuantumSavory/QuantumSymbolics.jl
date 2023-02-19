# This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are homogeneous in their arguments.

#This code defines a Julia struct called SymQ which represents a symbolic quantum object with a name and basis, and implements the Symbolic{T} interface for use in symbolic computations.
struct SymQ{T<:QObj} <: Symbolic{T}
    name::Symbol
    basis::Basis # From QuantumOpticsBase # TODO make QuantumInterface
end
istree(::SymQ) = false
metadata(::SymQ) = nothing
basis(x::SymQ) = x.basis

# This code defines the visual output for Kets, Operators, and Bras.
const SKet = SymQ{AbstractKet}
Base.show(io::IO, x::SKet) = print(io, "|$(x.name)⟩")
const SOperator = SymQ{AbstractOperator}
Base.show(io::IO, x::SOperator) = print(io, "$(x.name)")
const SBra = SymQ{AbstractBra}
Base.show(io::IO, x::SBra) = print(io, "⟨$(x.name)|")

# This code allows for scaling of a quantum object (ket, operator, or bra) by a number.
@withmetadata struct SScaled{T<:QObj} <: Symbolic{T}
    coeff
    obj
    SScaled{S}(c,k) where S = _isone(c) ? k : new{S}(c,k)
end
istree(::SScaled) = true
arguments(x::SScaled) = [x.coeff, x.obj]
operation(x::SScaled) = *
Base.:(*)(c, x::Symbolic{T}) where {T<:QObj} = SScaled{T}(c,x)
Base.:(*)(x::Symbolic{T}, c) where {T<:QObj} = SScaled{T}(c,x)
Base.:(/)(x::Symbolic{T}, c) where {T<:QObj} = SScaled{T}(1/c,x)
basis(x::SScaled) = basis(x.obj)

# This code defines the visual output for scaled kets, operators, and bras.
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
        print(io, "$(x.obj)$(x.coeff)")
    else
        print(io, "$(x.obj)($(x.coeff))")
    end
end

# This code allows for addition of quantum objects (kets, operators, or bras).
@withmetadata struct SAdd{T<:QObj} <: Symbolic{T}
    dict
    SAdd{S}(d) where S = length(d)==1 ? SScaled{S}(reverse(first(d))...) : new{S}(d)
end
istree(::SAdd) = true
arguments(x::SAdd) = [SScaledKet(v,k) for (k,v) in pairs(x.dict)]
operation(x::SAdd) = +
Base.:(+)(xs::Vararg{Symbolic{T},N}) where {T<:QObj,N} = SAdd{T}(countmap_flatten(xs, SScaled{T}))
Base.:(+)(xs::Vararg{Symbolic{<:QObj},0}) = 0 # to avoid undefined type parameters issue in the above method
basis(x::SAdd) = basis(first(x.dict).first)

# This code defines the visual output for added kets, operators, and bras.
const SAddKet = SAdd{AbstractKet}
Base.show(io::IO, x::SAddKet) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddOperator = SAdd{AbstractOperator}
Base.show(io::IO, x::SAddOperator) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddBra = SAdd{AbstractBra}
Base.show(io::IO, x::SAddBra) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference

# This code allows for tensor product of quantum objects (kets, operators, or bras).
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
⊗(xs::Symbolic{T}...) where {T<:QObj} = STensor{T}(collect(xs))
basis(x::STensor) = tensor(basis.(x.terms)...)

# This code defines the visual output for tensor product of kets, operators, and bras.
const STensorKet = STensor{AbstractKet}
Base.show(io::IO, x::STensorKet) = print(io, join(map(string, arguments(x)),""))
const STensorOperator = STensor{AbstractOperator}
Base.show(io::IO, x::STensorOperator) = print(io, join(map(string, arguments(x)),"⊗"))
const STensorSuperOperator = STensor{AbstractSuperOperator}
Base.show(io::IO, x::STensorSuperOperator) = print(io, join(map(string, arguments(x)),"⊗"))
const STensorBra = STensor{AbstractBra}
Base.show(io::IO, x::STensorBra) = print(io, join(map(string, arguments(x)),""))