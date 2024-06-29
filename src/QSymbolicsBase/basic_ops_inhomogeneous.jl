##
# This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments.
##

"""Symbolic application of an operator on a ket (from the left)

```jldoctest
julia> @ket k; @op A;

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
Base.:(*)(op::SZeroOperator, k::Symbolic{AbstractKet}) = SZeroKet()
Base.:(*)(op::Symbolic{AbstractOperator}, k::SZeroKet) = SZeroKet()
Base.:(*)(op::SZeroOperator, k::SZeroKet) = SZeroKet()
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right)

```jldoctest
julia> @bra b; @op A;

julia> b*A
⟨b|A
```
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
Base.:(*)(b::SZeroBra, op::Symbolic{AbstractOperator}) = SZeroBra()
Base.:(*)(b::Symbolic{AbstractBra}, op::SZeroOperator) = SZeroBra()
Base.:(*)(b::SZeroBra, op::SZeroOperator) = SZeroBra()
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket

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
Base.:(*)(b::Symbolic{AbstractBra}, k::Symbolic{AbstractKet}) = SBraKet(b,k)
Base.:(*)(b::SZeroBra, k::Symbolic{AbstractKet}) = 0
Base.:(*)(b::Symbolic{AbstractBra}, k::SZeroKet) = 0
Base.:(*)(b::SZeroBra, k::SZeroKet) = 0
Base.show(io::IO, x::SBraKet) = begin print(io,x.bra); print(io,x.ket) end
Base.hash(x::SBraKet, h::UInt) = hash((head(x), arguments(x)), h)
Base.isequal(x::SBraKet, y::SBraKet) = isequal(x.bra, y.bra) && isequal(x.ket, y.ket)

"""Symbolic application of a superoperator on an operator"""
@withmetadata struct SSuperOpApply <: Symbolic{AbstractOperator}
    sop
    op
end
isexpr(::SSuperOpApply) = true
iscall(::SSuperOpApply) = true
arguments(x::SSuperOpApply) = [x.sop,x.op]
operation(x::SSuperOpApply) = *
head(x::SSuperOpApply) = :*
children(x::SSuperOpApply) = [:*,x.sop,x.op]
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::Symbolic{AbstractOperator}) = SSuperOpApply(sop,op)
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::SZeroOperator) = SZeroOperator()
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::Symbolic{AbstractKet}) = SSuperOpApply(sop,SProjector(k))
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::SZeroKet) = SZeroKet()
Base.show(io::IO, x::SSuperOpApply) = begin print(io, x.sop); print(io, x.op) end
basis(x::SSuperOpApply) = basis(x.op)

"""Symbolic outer product of a ket and a bra
```jldoctest 
julia> @bra b; @ket k;

julia> k*b 
|k⟩⟨b|
```
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
Base.:(*)(k::SZeroKet, b::Symbolic{AbstractBra}) = SZeroOperator()
Base.:(*)(k::Symbolic{AbstractKet}, b::SZeroBra) = SZeroOperator()
Base.:(*)(k::SZeroKet, b::SZeroBra) = SZeroOperator()
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
