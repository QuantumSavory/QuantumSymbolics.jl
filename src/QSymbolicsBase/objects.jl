"""This file defines quantum objects (kets, bras, and operators) with various properties"""
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

ishermitian(x::SOperator) = false
isunitary(x::SOperator) = false
iscommutative(x::SOperator) = false

"""Inverse Operator"""
@withmetadata struct SInverseOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
istree(::SInverseOperator) = true
arguments(x::SInverseOperator) = [x.op]
basis(x::SInverseOperator) = basis(x.op)
Base.show(io::IO, x::SInverseOperator) = print(io, "$(x.op)⁻¹")
operation(x::SInverseOperator) = inverse
exprhead(x::SInverseOperator) = :inverse 
inverse(x::Symbolic{AbstractOperator}) = SInverseOperator(x)

"""Hermitian Operator"""
@withmetadata struct SHermitianOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
istree(::SHermitianOperator) = false
arguments(x::SHermitianOperator) = [x.op]
basis(x::SHermitianOperator) = basis(x.op)
Base.show(io::IO, x::SHermitianOperator) = print(io, "$(x.op)")
operation(x::SHermitianOperator) = hermitian
exprhead(x::SHermitianOperator) = :hermitian
hermitian(x::Symbolic{AbstractOperator}) = SHermitianOperator(x)
ishermitian(x::SHermitianOperator) = true

"""Unitary Operator"""
@withmetadata struct SUnitaryOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
istree(::SUnitaryOperator) = false
arguments(x::SUnitaryOperator) = [x.op]
basis(x::SUnitaryOperator) = basis(x.op)
Base.show(io::IO, x::SUnitaryOperator) = print(io, "$(x.op)")
operation(x::SUnitaryOperator) = unitary
exprhead(x::SUnitaryOperator) = :unitary
unitary(x::Symbolic{AbstractOperator}) = SUnitaryOperator(x)
isunitary(x::SUnitaryOperator) = true

"""Commutative Operator"""
@withmetadata struct SCommutativeOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
istree(::SCommutativeOperator) = false
arguments(x::SCommutativeOperator) = [x.op]
basis(x::SCommutativeOperator) = basis(x.op)
Base.show(io::IO, x::SCommutativeOperator) = print(io, "$(x.op)")
operation(x::SCommutativeOperator) = commutative
exprhead(x::SCommutativeOperator) = :commutative
commutative(x::Symbolic{AbstractOperator}) = SCommutativeOperator(x)
iscommutative(x::SCommutativeOperator) = true
