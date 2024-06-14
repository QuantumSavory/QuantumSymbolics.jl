"""This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments."""

"""Symbolic application of an operator on a ket (from the left)

```jldoctest
julia> k = SKet(:k, SpinBasis(1//2)); A = SOperator(:A, SpinBasis(1//2));

julia> A*k
A|k⟩
```
"""
@withmetadata struct SApplyKet <: Symbolic{AbstractKet}
    op
    ket
    function SApplyKet(o, k)
        coeff, cleanterms = prefactorscalings([o k])
        coeff*new(cleanterms...)
    end
end
isexpr(::SApplyKet) = true
iscall(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
head(x::SApplyKet) = :*
children(x::SApplyKet) = [:*,x.op,x.ket]
Base.:(*)(op::Symbolic{AbstractOperator}, k::Symbolic{AbstractKet}) = SApplyKet(op,k)
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right)

```jldoctest
julia> b = SBra(:b, SpinBasis(1//2)); A = SOperator(:A, SpinBasis(1//2));

julia> b*A
⟨b|A
"""
@withmetadata struct SApplyBra <: Symbolic{AbstractBra}
    bra
    op
    function SApplyBra(b, o)
        coeff, cleanterms = prefactorscalings([b o])
        coeff*new(cleanterms...)
    end
end
isexpr(::SApplyBra) = true
iscall(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
head(x::SApplyBra) = :*
children(x::SApplyBra) = [:*,x.bra,x.op]
Base.:(*)(b::Symbolic{AbstractBra}, op::Symbolic{AbstractOperator}) = SApplyBra(b,op)
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket

```jldoctest
julia> b = SBra(:b, SpinBasis(1//2)); k = SKet(:k, SpinBasis(1//2));

julia> b*k
⟨b||k⟩
```
"""
@withmetadata struct SBraKet <: Symbolic{Complex}
    bra
    ket
    function SBraKet(b, k)
        coeff, cleanterms = prefactorscalings([b k])
        coeff*new(cleanterms...)
    end
end
isexpr(::SBraKet) = true
iscall(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.ket]
operation(x::SBraKet) = *
head(x::SBraKet) = :*
children(x::SBraKet) = [:*,x.bra,x.ket]
Base.:(*)(b::Symbolic{AbstractBra}, k::Symbolic{AbstractKet}) = SBraKet(b,k)
Base.show(io::IO, x::SBraKet) = begin print(io,x.bra); print(io,x.ket) end

"""Symbolic application of a superoperator on an operator"""
@withmetadata struct SApplyOpSuper <: Symbolic{AbstractOperator}
    sop
    op
end
isexpr(::SApplyOpSuper) = true
iscall(::SApplyOpSuper) = true
arguments(x::SApplyOpSuper) = [x.sop,x.op]
operation(x::SApplyOpSuper) = *
head(x::SApplyOpSuper) = :*
children(x::SApplyOpSuper) = [:*,x.sop,x.op]
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::Symbolic{AbstractOperator}) = SApplyOpSuper(sop,op)
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::Symbolic{AbstractKet}) = SApplyOpSuper(sop,SProjector(k))
Base.show(io::IO, x::SApplyOpSuper) = begin print(io, x.sop); print(io, x.op) end
basis(x::SApplyOpSuper) = basis(x.op)

"""Symbolic outer product of a ket and a bra
```jldoctest 
julia> b = SBra(:b, SpinBasis(1//2)); k = SKet(:k, SpinBasis(1//2));

julia> k*b 
|k⟩⟨b|
"""
@withmetadata struct SOuterKetBra <: Symbolic{AbstractOperator}
    ket
    bra
    function SOuterKetBra(k, b)
        coeff, cleanterms = prefactorscalings([k b])
        coeff*new(cleanterms...)
    end
end
isexpr(::SOuterKetBra) = true
iscall(::SOuterKetBra) = true
arguments(x::SOuterKetBra) = [x.ket,x.bra]
operation(x::SOuterKetBra) = *
head(x::SOuterKetBra) = :*
children(x::SOuterKetBra) = [:*,x.ket,x.bra]
Base.:(*)(k::Symbolic{AbstractKet}, b::Symbolic{AbstractBra}) = SOuterKetBra(k,b)
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
