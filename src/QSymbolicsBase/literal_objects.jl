##
# This file defines quantum objects (kets, bras, and operators) with various properties
##

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
ishermitian(x::SOperator) = false
isunitary(x::SOperator) = false

struct SHermitianOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
ishermitian(::SHermitianOperator) = true
isunitary(::SHermitianOperator) = false

struct SUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
ishermitian(::SUnitaryOperator) = false
isunitary(::SUnitaryOperator) = true

struct SHermitianUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
ishermitian(::SHermitianUnitaryOperator) = true
isunitary(::SHermitianUnitaryOperator) = true

const SymQ = Union{SKet,SBra,SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator}
isexpr(::SymQ) = false
metadata(::SymQ) = nothing
symbollabel(x::SymQ) = x.name
basis(x::SymQ) = x.basis

Base.show(io::IO, x::SKet) = print(io, "|$(symbollabel(x))⟩")
Base.show(io::IO, x::SBra) = print(io, "⟨$(symbollabel(x))|")
Base.show(io::IO, x::Union{SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator}) = print(io, "$(symbollabel(x))")
Base.show(io::IO, x::SymQObj) = print(io, symbollabel(x)) # fallback that probably is not great

struct SZero{T<:QObj} <: Symbolic{T} end

const SZeroBra = SZero{AbstractBra}

const SZeroKet = SZero{AbstractKet}

const SZeroOperator = SZero{AbstractOperator}

isexpr(::SZero) = false
metadata(::SZero) = nothing
symbollabel(x::SZero) =  "𝟎"
basis(x::SZero) = nothing

Base.show(io::IO, x::SZero) = print(io, symbollabel(x))
Base.iszero(x::SymQObj) = isa(x, SZero)
