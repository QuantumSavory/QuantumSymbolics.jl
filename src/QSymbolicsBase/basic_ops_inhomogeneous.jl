##
# This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments.
##

"""Symbolic application of an operator on a ket (from the left).

```jldoctest
julia> @ket k; @op A;

julia> A*k
A|k⟩
```
"""
@withmetadata struct SApplyKet <: QSymbolic{AbstractKet}
    op
    ket
end
isexpr(::SApplyKet) = true
iscall(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
head(x::SApplyKet) = :*
children(x::SApplyKet) = [:*,x.op,x.ket]
function Base.:(*)(op::QSymbolic{AbstractOperator}, k::QSymbolic{AbstractKet})
    if !(samebases(basis(op),basis(k)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([op k])
        coeff*SApplyKet(cleanterms...)
    end
end
Base.:(*)(op::SZeroOperator, k::QSymbolic{AbstractKet}) = SZeroKet()
Base.:(*)(op::QSymbolic{AbstractOperator}, k::SZeroKet) = SZeroKet()
Base.:(*)(op::SZeroOperator, k::SZeroKet) = SZeroKet()
function Base.show(io::IO, x::SApplyKet) 
    str_func = x -> x isa SAdd || x isa STensorOperator ? "("*string(x)*")" : string(x)
    print(io, join(map(str_func, arguments(x)),""))
end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right).

```jldoctest
julia> @bra b; @op A;

julia> b*A
⟨b|A
```
"""
@withmetadata struct SApplyBra <: QSymbolic{AbstractBra}
    bra
    op
end
isexpr(::SApplyBra) = true
iscall(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
head(x::SApplyBra) = :*
children(x::SApplyBra) = [:*,x.bra,x.op]
function Base.:(*)(b::QSymbolic{AbstractBra}, op::QSymbolic{AbstractOperator}) 
    if !(samebases(basis(b),basis(op)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([b op])
        coeff*SApplyBra(cleanterms...)
    end
end
Base.:(*)(b::SZeroBra, op::QSymbolic{AbstractOperator}) = SZeroBra()
Base.:(*)(b::QSymbolic{AbstractBra}, op::SZeroOperator) = SZeroBra()
Base.:(*)(b::SZeroBra, op::SZeroOperator) = SZeroBra()
function Base.show(io::IO, x::SApplyBra) 
    str_func = x -> x isa SAdd || x isa STensorOperator ? "("*string(x)*")" : string(x)
    print(io, join(map(str_func, arguments(x)),""))
end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket.

```jldoctest
julia> @bra b; @ket k;

julia> b*k
⟨b||k⟩
```
"""
@withmetadata struct SBraKet <: QSymbolic{Complex}
    bra
    ket
end
isexpr(::SBraKet) = true
iscall(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.ket]
operation(x::SBraKet) = *
head(x::SBraKet) = :*
children(x::SBraKet) = [:*,x.bra,x.ket]
function Base.:(*)(b::QSymbolic{AbstractBra}, k::QSymbolic{AbstractKet}) 
    if !(samebases(basis(b),basis(k)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([b k])
        coeff == 1 ? SBraKet(cleanterms...) : coeff*SBraKet(cleanterms...)
    end
end
Base.:(*)(b::SZeroBra, k::QSymbolic{AbstractKet}) = 0
Base.:(*)(b::QSymbolic{AbstractBra}, k::SZeroKet) = 0
Base.:(*)(b::SZeroBra, k::SZeroKet) = 0
Base.show(io::IO, x::SBraKet) = begin print(io,x.bra); print(io,x.ket) end
Base.hash(x::SBraKet, h::UInt) = hash((head(x), arguments(x)), h)
maketerm(::Type{SBraKet}, f, a, m) = f(a...)
Base.isequal(x::SBraKet, y::SBraKet) = isequal(x.bra, y.bra) && isequal(x.ket, y.ket)

"""Symbolic outer product of a ket and a bra.

```jldoctest 
julia> @bra b; @ket k;

julia> k*b 
|k⟩⟨b|
```
"""
@withmetadata struct SOuterKetBra <: QSymbolic{AbstractOperator}
    ket
    bra
end
isexpr(::SOuterKetBra) = true
iscall(::SOuterKetBra) = true
arguments(x::SOuterKetBra) = [x.ket,x.bra]
operation(x::SOuterKetBra) = *
head(x::SOuterKetBra) = :*
children(x::SOuterKetBra) = [:*,x.ket,x.bra]
function Base.:(*)(k::QSymbolic{AbstractKet}, b::QSymbolic{AbstractBra})
    if !(samebases(basis(k),basis(b)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([k b])
        coeff*SOuterKetBra(cleanterms...)
    end
end
Base.:(*)(k::SZeroKet, b::QSymbolic{AbstractBra}) = SZeroOperator()
Base.:(*)(k::QSymbolic{AbstractKet}, b::SZeroBra) = SZeroOperator()
Base.:(*)(k::SZeroKet, b::SZeroBra) = SZeroOperator()
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
