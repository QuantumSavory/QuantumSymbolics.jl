##
# This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments.
##

"""Symbolic application of an operator on a ket (from the left).

```jldoctest
julia> @ket k; @op A;

julia> A*k
Â|k⟩
```
"""
@withmetadata struct SApplyKet <: Symbolic{AbstractKet}
    op
    ket
end
isexpr(::SApplyKet) = true
iscall(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
head(x::SApplyKet) = :*
children(x::SApplyKet) = [:*,x.op,x.ket]
function Base.:(*)(op::Symbolic{AbstractOperator}, k::Symbolic{AbstractKet})
    if !(samebases(basis(op),basis(k)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([op k])
        coeff*SApplyKet(cleanterms...)
    end
end
Base.:(*)(op::SZeroOperator, k::Symbolic{AbstractKet}) = SZeroKet()
Base.:(*)(op::Symbolic{AbstractOperator}, k::SZeroKet) = SZeroKet()
Base.:(*)(op::SZeroOperator, k::SZeroKet) = SZeroKet()
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right).

```jldoctest
julia> @bra b; @op A;

julia> b*A
⟨b|Â
```
"""
@withmetadata struct SApplyBra <: Symbolic{AbstractBra}
    bra
    op
end
isexpr(::SApplyBra) = true
iscall(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
head(x::SApplyBra) = :*
children(x::SApplyBra) = [:*,x.bra,x.op]
function Base.:(*)(b::Symbolic{AbstractBra}, op::Symbolic{AbstractOperator}) 
    if !(samebases(basis(b),basis(op)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([b op])
        coeff*SApplyBra(cleanterms...)
    end
end
Base.:(*)(b::SZeroBra, op::Symbolic{AbstractOperator}) = SZeroBra()
Base.:(*)(b::Symbolic{AbstractBra}, op::SZeroOperator) = SZeroBra()
Base.:(*)(b::SZeroBra, op::SZeroOperator) = SZeroBra()
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket.

```jldoctest
julia> @bra b; @ket k;

julia> b*k
⟨b||k⟩
```
"""
@withmetadata struct SBraKet <: Symbolic{Complex}
    bra
    ket
end
isexpr(::SBraKet) = true
iscall(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.ket]
operation(x::SBraKet) = *
head(x::SBraKet) = :*
children(x::SBraKet) = [:*,x.bra,x.ket]
function Base.:(*)(b::Symbolic{AbstractBra}, k::Symbolic{AbstractKet}) 
    if !(samebases(basis(b),basis(k)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([b k])
        coeff == 1 ? SBraKet(cleanterms...) : coeff*SBraKet(cleanterms...)
    end
end
Base.:(*)(b::SZeroBra, k::Symbolic{AbstractKet}) = 0
Base.:(*)(b::Symbolic{AbstractBra}, k::SZeroKet) = 0
Base.:(*)(b::SZeroBra, k::SZeroKet) = 0
Base.show(io::IO, x::SBraKet) = begin print(io,x.bra); print(io,x.ket) end
Base.hash(x::SBraKet, h::UInt) = hash((head(x), arguments(x)), h)
maketerm(::Type{SBraKet}, f, a, t, m) = f(a...)
Base.isequal(x::SBraKet, y::SBraKet) = isequal(x.bra, y.bra) && isequal(x.ket, y.ket)

"""Symbolic outer product of a ket and a bra.

```jldoctest 
julia> @bra b; @ket k;

julia> k*b 
|k⟩⟨b|
```
"""
@withmetadata struct SOuterKetBra <: Symbolic{AbstractOperator}
    ket
    bra
end
isexpr(::SOuterKetBra) = true
iscall(::SOuterKetBra) = true
arguments(x::SOuterKetBra) = [x.ket,x.bra]
operation(x::SOuterKetBra) = *
head(x::SOuterKetBra) = :*
children(x::SOuterKetBra) = [:*,x.ket,x.bra]
function Base.:(*)(k::Symbolic{AbstractKet}, b::Symbolic{AbstractBra})
    if !(samebases(basis(k),basis(b)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([k b])
        coeff*SOuterKetBra(cleanterms...)
    end
end
Base.:(*)(k::SZeroKet, b::Symbolic{AbstractBra}) = SZeroOperator()
Base.:(*)(k::Symbolic{AbstractKet}, b::SZeroBra) = SZeroOperator()
Base.:(*)(k::SZeroKet, b::SZeroBra) = SZeroOperator()
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
