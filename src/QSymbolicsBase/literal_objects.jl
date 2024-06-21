##
# This file defines quantum objects (kets, bras, and operators) with various properties
##

struct SBra <: Symbolic{AbstractBra}
    name::Symbol
    basis::Basis
end
SBra(name) = SBra(name, qubit_basis)
macro bra(name, basis)
    :($(esc(name)) = SBra($(Expr(:quote, name)), $(basis)))
end
macro bra(name)
    :($(esc(name)) = SBra($(Expr(:quote, name))))
end

struct SKet <: Symbolic{AbstractKet}
    name::Symbol
    basis::Basis
end
SKet(name) = SKet(name, qubit_basis)
macro ket(name, basis)
    :($(esc(name)) = SKet($(Expr(:quote, name)), $(basis)))
end
macro ket(name)
    :($(esc(name)) = SKet($(Expr(:quote, name))))
end

struct SOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SOperator(name) = SOperator(name, qubit_basis)
macro op(name, basis)
    :($(esc(name)) = SOperator($(Expr(:quote, name)), $(basis)))
end
macro op(name)
    :($(esc(name)) = SOperator($(Expr(:quote, name))))
end
ishermitian(x::SOperator) = false
isunitary(x::SOperator) = false

struct SHermitianOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SHermitianOperator(name) = SHermitianOperator(name, qubit_basis)

ishermitian(::SHermitianOperator) = true
isunitary(::SHermitianOperator) = false

struct SUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SUnitaryOperator(name) = SUnitaryOperator(name, qubit_basis)

ishermitian(::SUnitaryOperator) = false
isunitary(::SUnitaryOperator) = true

struct SHermitianUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SHermitianUnitaryOperator(name) = SHermitianUnitaryOperator(name, qubit_basis)

ishermitian(::SHermitianUnitaryOperator) = true
isunitary(::SHermitianUnitaryOperator) = true

const SymQ = Union{SKet, SBra, SOperator, SHermitianOperator, SUnitaryOperator, SHermitianUnitaryOperator}
isexpr(::SymQ) = false
metadata(::SymQ) = nothing
symbollabel(x::SymQ) = x.name
basis(x::SymQ) = x.basis

Base.show(io::IO, x::SKet) = print(io, "|$(symbollabel(x))⟩")
Base.show(io::IO, x::SBra) = print(io, "⟨$(symbollabel(x))|")
Base.show(io::IO, x::Union{SOperator, SHermitianOperator, SUnitaryOperator, SHermitianUnitaryOperator}) = print(io, "$(symbollabel(x))")
Base.show(io::IO, x::SymQObj) = print(io, symbollabel(x)) # fallback that probably is not great
