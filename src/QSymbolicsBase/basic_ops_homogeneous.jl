"""This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are homogeneous in their arguments."""

"""Scaling of a quantum object (ket, operator, or bra) by a number

```jldoctest
julia> k = SKet(:k, SpinBasis(1//2))
|k⟩

julia> 2*k
2|k⟩

julia> A = SOperator(:A, SpinBasis(1//2))
A 

julia> 2*A
2A
````
"""
@withmetadata struct SScaled{T<:QObj} <: Symbolic{T}
    coeff
    obj
    SScaled{S}(c,k) where S = _isone(c) ? k : new{S}(c,k)
end
isexpr(::SScaled) = true
iscall(::SScaled) = true
arguments(x::SScaled) = [x.coeff,x.obj]
operation(x::SScaled) = *
head(x::SScaled) = :*
children(x::SScaled) = [:*,x.coeff,x.obj]
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

"""Addition of quantum objects (kets, operators, or bras)

```jldoctest
julia> k₁ = SKet(:k₁, SpinBasis(1//2)); k₂ = SKet(:k₂, SpinBasis(1//2));

julia> k₁ + k₂
(|k₁⟩+|k₂⟩)
```
"""
@withmetadata struct SAdd{T<:QObj} <: Symbolic{T}
    dict
    SAdd{S}(d) where S = length(d)==1 ? SScaled{S}(reverse(first(d))...) : new{S}(d)
end
isexpr(::SAdd) = true
iscall(::SAdd) = true
arguments(x::SAdd) = [SScaledKet(v,k) for (k,v) in pairs(x.dict)]
operation(x::SAdd) = +
head(x::SAdd) = :+
children(x::SAdd) = [:+,SScaledKet(v,k) for (k,v) in pairs(x.dict)]
Base.:(+)(xs::Vararg{Symbolic{T},N}) where {T<:QObj,N} = SAdd{T}(countmap_flatten(xs, SScaled{T}))
Base.:(+)(xs::Vararg{Symbolic{<:QObj},0}) = 0 # to avoid undefined type parameters issue in the above method
basis(x::SAdd) = basis(first(x.dict).first)

const SAddKet = SAdd{AbstractKet}
Base.show(io::IO, x::SAddKet) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddOperator = SAdd{AbstractOperator}
Base.show(io::IO, x::SAddOperator) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference
const SAddBra = SAdd{AbstractBra}
Base.show(io::IO, x::SAddBra) = print(io, "("*join(map(string, arguments(x)),"+")::String*")") # type assert to help inference

# defines commutativity for addition of quantum objects
const CommQObj = Union{SAddBra, SAddKet, SAddOperator} 
function _in(x::SymQObj, sadd::CommQObj)
    for i in arguments(sadd)
        if isequal(x, i)
            return true
        end
    end
    false
end
function Base.isequal(x::CommQObj, y::CommQObj)
    if typeof(x)==typeof(y)
        if isexpr(x)
            if operation(x)==operation(y)
                ax,ay = arguments(x),arguments(y)
                (length(ax) == length(ay)) && all(x -> _in(x, y), ax)
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

"""Symbolic application of operator on operator

```jldoctest
julia> A = SOperator(:A, SpinBasis(1//2)); B = SOperator(:B, SpinBasis(1//2));

julia> A*B 
AB
```
"""
@withmetadata struct SMulOperator <: Symbolic{AbstractOperator}
    terms
    function SMulOperator(terms)
        coeff, cleanterms = prefactorscalings(terms)
        coeff*new(cleanterms)
    end
end
isexpr(::SMulOperator) = true
iscall(::SMulOperator) = true
arguments(x::SMulOperator) = x.terms
operation(x::SMulOperator) = *
head(x::SMulOperator) = :*
children(x::SMulOperator) = pushfirst!(x.terms,:*)
Base.:(*)(xs::Symbolic{AbstractOperator}...) = SMulOperator(collect(xs))
Base.show(io::IO, x::SMulOperator) = print(io, join(map(string, arguments(x)),""))
basis(x::SMulOperator) = basis(x.terms)

"""Tensor product of quantum objects (kets, operators, or bras)

```jldoctest
julia> k₁ = SKet(:k₁, SpinBasis(1//2)); k₂ = SKet(:k₂, SpinBasis(1//2));

julia> k₁ ⊗ k₂
|k₁⟩|k₂⟩

julia> A = SOperator(:A, SpinBasis(1//2)); B = SOperator(:B, SpinBasis(1//2));

julia> A ⊗ B 
A⊗B
```
"""
@withmetadata struct STensor{T<:QObj} <: Symbolic{T}
    terms
    function STensor{S}(terms) where S
        coeff, cleanterms = prefactorscalings(terms)
        coeff * new{S}(cleanterms)
    end
end
isexpr(::STensor) = true
iscall(::STensor) = true
arguments(x::STensor) = x.terms
operation(x::STensor) = ⊗
head(x::STensor) = :⊗
children(x::STensor) = pushfirst!(x.terms,:⊗)
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

"""Symbolic commutator of two operators

```jldoctest
julia> A = SOperator(:A, SpinBasis(1//2)); B = SOperator(:B, SpinBasis(1//2));

julia> commutator(A, B)
[A,B]

julia> commutator(A, A)
0
```
"""
@withmetadata struct SCommutator <: Symbolic{AbstractOperator}
    op1
    op2
    function SCommutator(o1, o2) 
        coeff, cleanterms = prefactorscalings([o1 o2])
        cleanterms[1] === cleanterms[2] ? 0 : coeff*new(cleanterms...)
    end
end
isexpr(::SCommutator) = true
iscall(::SCommutator) = true
arguments(x::SCommutator) = [x.op1, x.op2]
operation(x::SCommutator) = commutator
head(x::SCommutator) = :commutator
children(x::SCommutator) = [:commutator, x.op1, x.op2]
commutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator}) = SCommutator(o1, o2)
Base.show(io::IO, x::SCommutator) = print(io, "[$(x.op1),$(x.op2)]")
basis(x::SCommutator) = basis(x.op1)
expand(x::SCommutator) = x == 0 ? x : x.op1*x.op2 - x.op2*x.op1

"""Symbolic anticommutator of two operators

```jldoctest
julia> A = SOperator(:A, SpinBasis(1//2)); B = SOperator(:B, SpinBasis(1//2));

julia> anticommutator(A, B)
{A,B}
```
"""
@withmetadata struct SAnticommutator <: Symbolic{AbstractOperator}
    op1
    op2
    function SAnticommutator(o1, o2) 
        coeff, cleanterms = prefactorscalings([o1 o2])
        coeff*new(cleanterms...)
    end
end
isexpr(::SAnticommutator) = true
iscall(::SAnticommutator) = true
arguments(x::SAnticommutator) = [x.op1, x.op2]
operation(x::SAnticommutator) = anticommutator
head(x::SAnticommutator) = :anticommutator
children(x::SAnticommutator) = [:anticommutator, x.op1, x.op2]
anticommutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator}) = SAnticommutator(o1, o2)
Base.show(io::IO, x::SAnticommutator) = print(io, "{$(x.op1),$(x.op2)}")
basis(x::SAnticommutator) = basis(x.op1)
expand(x::SAnticommutator) = x == 0 ? x : x.op1*x.op2 + x.op2*x.op1
