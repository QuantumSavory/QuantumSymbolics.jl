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
isexpr(::SymQ) = false
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
isexpr(::SInverseOperator) = true
iscall(::SInverseOperator) = true
arguments(x::SInverseOperator) = [x.op]
operation(x::SInverseOperator) = inverse
head(x::SInverseOperator) = :inverse 
children(x::SInverseOperator) = [:inverse, x.op]
basis(x::SInverseOperator) = basis(x.op)
Base.show(io::IO, x::SInverseOperator) = print(io, "$(x.op)⁻¹")
inverse(x::Symbolic{AbstractOperator}) = SInverseOperator(x)

"""Hermitian Operator"""
@withmetadata struct SHermitianOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SHermitianOperator) = false
basis(x::SHermitianOperator) = basis(x.op)
Base.show(io::IO, x::SHermitianOperator) = print(io, "$(x.op)")
hermitian(x::Symbolic{AbstractOperator}) = SHermitianOperator(x)
ishermitian(::SHermitianOperator) = true

"""Unitary Operator"""
@withmetadata struct SUnitaryOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SUnitaryOperator) = false
basis(x::SUnitaryOperator) = basis(x.op)
Base.show(io::IO, x::SUnitaryOperator) = print(io, "$(x.op)")
unitary(x::Symbolic{AbstractOperator}) = SUnitaryOperator(x)
isunitary(::SUnitaryOperator) = true

"""Commutative Operator"""
@withmetadata struct SCommutativeOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SCommutativeOperator) = false
basis(x::SCommutativeOperator) = basis(x.op)
Base.show(io::IO, x::SCommutativeOperator) = print(io, "$(x.op)")
commutative(x::Symbolic{AbstractOperator}) = SCommutativeOperator(x)
iscommutative(::SCommutativeOperator) = true
