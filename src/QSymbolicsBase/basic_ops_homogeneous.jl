##
# This file defines the symbolic operations for quantum objects (kets, operators, and bras)
# that are homogeneous in their arguments.
##

"""Scaling of a quantum object (ket, operator, or bra) by a number.

```jldoctest
julia> @ket k
|k⟩

julia> 2*k
2|k⟩

julia> @op A
A

julia> 2*A
2A
```
"""
@withmetadata struct SScaled{T<:QObj,C<:SymCoeff,O<:Symbolic{T}} <: Symbolic{T}
    coeff::C
    obj::O
end
SScaled{T}(coeff::C, obj::O) where {T<:QObj,C<:SymCoeff,O<:Symbolic{T}} = SScaled{T,C,O}(coeff, obj)
SScaled(coeff::SymCoeff, obj::Symbolic{T}) where {T<:QObj} = SScaled{T}(coeff, obj)
isexpr(::SScaled) = true
iscall(::SScaled) = true
arguments(x::SScaled) = [x.coeff,x.obj]
operation(x::SScaled) = *
head(x::SScaled) = :*
children(x::SScaled) = [:*,x.coeff,x.obj]
function Base.:(*)(c::U, x::Symbolic{T}) where {U<:SymCoeff,T<:QObj}
    if (c isa Number && iszero(c)) || iszero(x)
        SZero{T}()
    elseif _isone(c)
        x
    elseif isa(x, SScaled)
        SScaled{T}(c*x.coeff, x.obj)
    else
        SScaled{T}(c, x)
    end
end

Base.:(*)(x::Symbolic{T}, c::Number) where {T<:QObj} = c*x
Base.:(*)(x::Symbolic{T}, y::Symbolic{S}) where {T<:QObj,S<:QObj} = throw(ArgumentError("multiplication between $(typeof(x)) and $(typeof(y)) is not defined; maybe you are looking for a tensor product `tensor`"))
Base.:(/)(x::Symbolic{T}, c::Number) where {T<:QObj} = iszero(c) ? throw(DomainError(c,"cannot divide QSymbolics expressions by zero")) : (1/c)*x
basis(x::SScaled) = basis(x.obj)

const SScaledKet = SScaled{AbstractKet}
function Base.show(io::IO, x::SScaledKet)
    if x.coeff isa Real
        if x.obj isa SAddKet
            print(io, "$(x.coeff)($(x.obj))")
        else
            print(io, "$(x.coeff)$(x.obj)")
        end
    else
        if x.obj isa SAddKet
            print(io, "($(x.coeff))($(x.obj))")
        else
            print(io, "($(x.coeff))$(x.obj)")
        end
    end
end
const SScaledOperator = SScaled{AbstractOperator}
function Base.show(io::IO, x::SScaledOperator)
    if x.coeff isa Real
        if x.obj isa SAddOperator
            print(io, "$(x.coeff)($(x.obj))")
        else
            print(io, "$(x.coeff)$(x.obj)")
        end
    else
        if x.obj isa SAddOperator
            print(io, "($(x.coeff))($(x.obj))")
        else
            print(io, "($(x.coeff))$(x.obj)")
        end
    end
end
const SScaledBra = SScaled{AbstractBra}
function Base.show(io::IO, x::SScaledBra)
    if x.coeff isa Real
        if x.obj isa SAddBra
            print(io, "$(x.coeff)($(x.obj))")
        else
            print(io, "$(x.coeff)$(x.obj)")
        end
    else
        if x.obj isa SAddBra
            print(io, "($(x.coeff))($(x.obj))")
        else
            print(io, "($(x.coeff))$(x.obj)")
        end
    end
end

"""The mapping from the terms of a symbolic sum to their scalar coefficients."""
const SAddDict{T} = Dict{Symbolic{T},SymCoeff}

"""Addition of quantum objects (kets, operators, or bras).

```jldoctest
julia> @ket k₁; @ket k₂;

julia> k₁ + k₂
|k₁⟩+|k₂⟩
```
"""
@withmetadata struct SAdd{T<:QObj} <: Symbolic{T}
    dict::SAddDict{T}
    _set_precomputed::Set{Symbolic{T}}
    _arguments_precomputed::Vector{Symbolic{T}}
end
function SAdd{T}(d) where {T<:QObj}
    isempty(d) && return SZero{T}()
    terms = Symbolic{T}[c*obj for (obj,c) in d]
    length(d)==1 ? first(terms) : SAdd{T}(d,Set(terms),terms)
end
isexpr(::SAdd) = true
iscall(::SAdd) = true
arguments(x::SAdd) = x._arguments_precomputed
operation(x::SAdd) = +
head(x::SAdd) = :+
children(x::SAdd) = [:+; x._arguments_precomputed]
function Base.:(+)(x::Symbolic{T}, xs::Vararg{Symbolic{T}, N}) where {T<:QObj, N}
    terms = Symbolic{T}[x, xs...]
    f = first(terms)
    nonzero_terms = filter!(x->!iszero(x),terms)
    isempty(nonzero_terms) ? f : SAdd{T}(countmap_flatten(nonzero_terms, SAdd{T}, SScaled{T}, Symbolic{T}))
end
basis(x::SAdd) = basis(first(x.dict).first)

const SAddBra = SAdd{AbstractBra}
function Base.show(io::IO, x::SAddBra)
    ordered_terms = sort([repr(i) for i in arguments(x)])
    print(io, join(ordered_terms,"+")::String) # type assert to help inference
end
const SAddKet = SAdd{AbstractKet}
function Base.show(io::IO, x::SAddKet)
    ordered_terms = sort([repr(i) for i in arguments(x)])
    print(io, join(ordered_terms,"+")::String) # type assert to help inference
end
const SAddOperator = SAdd{AbstractOperator}
function Base.show(io::IO, x::SAddOperator)
    repr_func = x -> x isa STensor ? "("*repr(x)*")" : repr(x)
    ordered_terms = sort([repr_func(i) for i in arguments(x)])
    print(io, join(ordered_terms,"+")::String) # type assert to help inference
end

"""Symbolic application of operator on operator.

```jldoctest
julia> @op A; @op B;

julia> A*B
AB
```
"""
@withmetadata struct SMulOperator <: Symbolic{AbstractOperator}
    terms::Vector{Symbolic{AbstractOperator}}
end
isexpr(::SMulOperator) = true
iscall(::SMulOperator) = true
arguments(x::SMulOperator) = x.terms
operation(x::SMulOperator) = *
head(x::SMulOperator) = :*
children(x::SMulOperator) = [:*;x.terms]
function Base.:(*)(x::Symbolic{AbstractOperator}, xs::Vararg{Symbolic{AbstractOperator}, N}) where {N}
    ops = Symbolic{AbstractOperator}[x, xs...]
    zero_ind = findfirst(x->iszero(x), ops)
    if isnothing(zero_ind)
        if any(x->!(samebases(basis(x),basis(first(ops)))),ops)
            throw(IncompatibleBases())
        else
            terms = flattenop(SMulOperator, ops)
            coeff, cleanterms = prefactorscalings(terms)
            coeff * SMulOperator(cleanterms)
        end
    else
        SZeroOperator()
    end
end
function Base.show(io::IO, x::SMulOperator)
    str_func = x -> x isa SAdd || x isa STensor ? "("*string(x)*")" : string(x)
    print(io, join(map(str_func, arguments(x)),""))
end
basis(x::SMulOperator) = basis(first(x.terms))

"""Tensor product of quantum objects (kets, operators, or bras).

```jldoctest
julia> @ket k₁; @ket k₂;

julia> k₁ ⊗ k₂
|k₁⟩|k₂⟩

julia> @op A; @op B;

julia> A ⊗ B
A⊗B
```
"""
@withmetadata struct STensor{T<:QObj} <: Symbolic{T}
    terms::Vector{Symbolic{T}}
end
isexpr(::STensor) = true
iscall(::STensor) = true
arguments(x::STensor) = x.terms
operation(x::STensor) = ⊗
head(x::STensor) = :⊗
children(x::STensor) = [:⊗; x.terms]
function ⊗(xs::Symbolic{T}...) where {T<:QObj}
    zero_ind = findfirst(x->iszero(x), xs)
    if isnothing(zero_ind)
        terms = flattenop(STensor{T}, Symbolic{T}[xs...])
        coeff, cleanterms = prefactorscalings(terms)
        coeff * STensor{T}(cleanterms)
    else
        SZero{T}()
    end
end
basis(x::STensor) = tensor(basis.(x.terms)...)

const STensorBra = STensor{AbstractBra}
Base.show(io::IO, x::STensorBra) = print(io, join(map(string, arguments(x)),""))
const STensorKet = STensor{AbstractKet}
Base.show(io::IO, x::STensorKet) = print(io, join(map(string, arguments(x)),""))
const STensorOperator = STensor{AbstractOperator}
function Base.show(io::IO, x::STensorOperator)
    str_func = x -> x isa SAdd ? "("*string(x)*")" : string(x)
    print(io, join(map(str_func, arguments(x)),"⊗"))
end
const STensorSuperOperator = STensor{AbstractSuperOperator}
function Base.show(io::IO, x::STensorSuperOperator)
    str_func = x -> x isa SAdd ? "("*string(x)*")" : string(x)
    print(io, join(map(str_func, arguments(x)),"⊗"))
end