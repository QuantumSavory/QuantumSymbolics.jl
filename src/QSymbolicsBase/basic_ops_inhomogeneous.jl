"""This file defines the symbolic operations for quantum objects (kets, operators, and bras) that are inhomogeneous in their arguments."""

"""Symbolic application of an operator on a ket (from the left)"""
@withmetadata struct SApplyKet <: Symbolic{AbstractKet}
    op
    ket
end
istree(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
exprhead(x::SApplyKet) = :*
Base.:(*)(op::Symbolic{AbstractOperator}, k::Symbolic{AbstractKet}) = SApplyKet(op,k)
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

"""Symbolic application of an operator on a bra (from the right)"""
@withmetadata struct SApplyBra <: Symbolic{AbstractBra}
    bra
    op
end
istree(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
exprhead(x::SApplyBra) = :*
Base.:(*)(b::Symbolic{AbstractBra}, op::Symbolic{AbstractOperator}) = SApplyBra(b,op)
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

"""Symbolic inner product of a bra and a ket."""
@withmetadata struct SBraKet <: Symbolic{Complex}
    bra
    ket
end
istree(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.ket]
operation(x::SBraKet) = *
exprhead(x::SBraKet) = :*
Base.:(*)(b::Symbolic{AbstractBra}, k::Symbolic{AbstractKet}) = SBraKet(b,k)
function Base.show(io::IO, x::SBraKet)
    print(io,x.bra)
    print(io,x.ket)
end

"""Symbolic application of a superoperator on an operator"""
@withmetadata struct SApplyOp <: Symbolic{AbstractOperator}
    sop
    op
end
istree(::SApplyOp) = true
arguments(x::SApplyOp) = [x.sop,x.op]
operation(x::SApplyOp) = *
exprhead(x::SApplyOp) = :*
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::Symbolic{AbstractOperator}) = SApplyOp(sop,op)
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::Symbolic{AbstractKet}) = SApplyOp(sop,SProjector(k))
Base.show(io::IO, x::SApplyOp) = begin print(io, x.sop); print(io, x.op) end
basis(x::SApplyOp) = basis(x.op)

"""Symbolic outer product of a ket and a bra"""
@withmetadata struct SOuterKetBra <: Symbolic{AbstractOperator}
    ket
    bra
end
istree(::SOuterKetBra) = true
arguments(x::SOuterKetBra) = [x.ket,x.bra]
operation(x::SOuterKetBra) = *
exprhead(x::SOuterKetBra) = :*
Base.:(*)(k::Symbolic{AbstractKet}, b::Symbolic{AbstractBra}) = SOuterKetBra(k,b)
Base.:(*)(k::SScaledKet, b::Symbolic{AbstractBra}) = k.coeff*SOuterKetBra(k.obj,b)
Base.:(*)(k::Symbolic{AbstractKet}, b::SScaledBra) = b.coeff*SOuterKetBra(k,b.obj)
Base.:(*)(k::SScaledKet, b::SScaledBra) = k.coeff*b.coeff*SOuterKetBra(k.obj,b.obj)
Base.show(io::IO, x::SOuterKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SOuterKetBra) = basis(x.ket)
