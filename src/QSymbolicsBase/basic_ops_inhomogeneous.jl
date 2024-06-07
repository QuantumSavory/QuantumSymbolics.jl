"""This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments."""

"""Symbolic application of an operator on a ket (from the left)"""
@withmetadata struct SApplyKet <: Symbolic{AbstractKet}
    op
    ket
    function SApplyKet(o, k)
        coeff, cleanterms = prefactorscalings([o k])
        coeff*new(cleanterms...)
    end
end
istree(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
exprhead(x::SApplyKet) = :*
Base.:(*)(o::Symbolic{AbstractOperator}, k::Symbolic{AbstractKet}) = SApplyKet(o,k)
Base.:(==)(x1::SApplyKet, x2::SApplyKet) = x1.op == x2.op && x1.ket == x2.ket
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right)"""
@withmetadata struct SApplyBra <: Symbolic{AbstractBra}
    bra
    op
    function SApplyBra(b, o)
        coeff, cleanterms = prefactorscalings([b o])
        coeff*new(cleanterms...)
    end
end
istree(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
exprhead(x::SApplyBra) = :*
Base.:(*)(b::Symbolic{AbstractBra}, o::Symbolic{AbstractOperator}) = SApplyKet(b,o)
Base.:(==)(x1::SApplyBra, x2::SApplyKet) = x1.bra == x2.bra && x1.op == x2.op
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket."""
@withmetadata struct SBraKet <: Symbolic{Complex}
    bra
    ket
    function SBraKet(b, k)
        coeff, cleanterms = prefactorscalings([b k])
        coeff*new(cleanterms...)
    end
end
istree(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.ket]
operation(x::SBraKet) = *
exprhead(x::SBraKet) = :*
Base.:(*)(b::Symbolic{AbstractBra}, k::Symbolic{AbstractKet}) = SBraKet(b,k)
Base.:(==)(x1::SBraKet, x2::SBraKet) = x1.bra == x2.bra && x1.ket == x2.ket
Base.show(io::IO, x::SBraKet) = begin print(io,x.bra); print(io,x.ket) end

"""Symbolic application of a superoperator on an operator"""
@withmetadata struct SApplyOpSuper <: Symbolic{AbstractOperator}
    sop
    op
end
istree(::SApplyOpSuper) = true
arguments(x::SApplyOpSuper) = [x.sop,x.op]
operation(x::SApplyOpSuper) = *
exprhead(x::SApplyOpSuper) = :*
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::Symbolic{AbstractOperator}) = SApplyOpSuper(sop,op)
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::Symbolic{AbstractKet}) = SApplyOpSuper(sop,SProjector(k))
Base.:(==)(x1::SApplyOpSuper, x2::SApplyOpSuper) = x1.sop == x2.sop && x1.op && x2.op
Base.show(io::IO, x::SApplyOpSuper) = begin print(io, x.sop); print(io, x.op) end
basis(x::SApplyOpSuper) = basis(x.op)

"""Symbolic outer product of a ket and a bra"""
@withmetadata struct SOuterKetBra <: Symbolic{AbstractOperator}
    ket
    bra
    function SOuterKetBra(k, b)
        coeff, cleanterms = prefactorscalings([k b])
        coeff*new(cleanterms...)
    end
end
istree(::SOuterKetBra) = true
arguments(x::SOuterKetBra) = [x.ket,x.bra]
operation(x::SOuterKetBra) = *
exprhead(x::SOuterKetBra) = :*
Base.:(*)(k::Symbolic{AbstractKet}, b::Symbolic{AbstractBra}) = SOuterKetBra(k,b)
Base.:(==)(x1::SOuterKetBra, x2::SOuterKetBra) = x1.ket == x2.ket && x1.bra && x2.bra
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
