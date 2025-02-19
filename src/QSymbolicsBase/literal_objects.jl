##
# This file defines quantum objects (kets, bras, and operators) with various properties
##

"""Symbolic bra"""
struct SBra <: Symbolic{AbstractBra}
    name::Symbol
    basis::Basis
end
SBra(name) = SBra(name, qubit_basis)

"""
    @bra(name, basis=SpinBasis(1//2))

Define a symbolic bra of type `SBra`. By default, the defined basis is the spin-1/2 basis.

```jldoctest
julia> @bra b₁
⟨b₁|

julia> @bra b₂ FockBasis(2)
⟨b₂|
```
"""
macro bra(name, basis)
    :($(esc(name)) = SBra($(Expr(:quote, name)), $(basis)))
end
macro bra(name)
    :($(esc(name)) = SBra($(Expr(:quote, name))))
end

"""Symbolic ket"""
struct SKet <: Symbolic{AbstractKet}
    name::Symbol
    basis::Basis
end
SKet(name) = SKet(name, qubit_basis)

"""
    @ket(name, basis=SpinBasis(1//2))

Define a symbolic ket of type `SKet`. By default, the defined basis is the spin-1/2 basis.

```jldoctest
julia> @ket k₁
|k₁⟩

julia> @ket k₂ FockBasis(2)
|k₂⟩
```
"""
macro ket(name, basis)
    :($(esc(name)) = SKet($(Expr(:quote, name)), $(basis)))
end
macro ket(name)
    :($(esc(name)) = SKet($(Expr(:quote, name))))
end

"""Symbolic operator"""
struct SOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SOperator(name) = SOperator(name, qubit_basis)

"""
    @op(name, basis=SpinBasis(1//2))

Define a symbolic operator of type `SOperator`. By default, the defined basis is the spin-1/2 basis.

```jldoctest
julia> @op A
A

julia> @op B FockBasis(2)
B
```
"""
macro op(name, basis)
    :($(esc(name)) = SOperator($(Expr(:quote, name)), $(basis)))
end
macro op(name)
    :($(esc(name)) = SOperator($(Expr(:quote, name))))
end
ishermitian(x::SOperator) = false
isunitary(x::SOperator) = false

"""Symbolic Hermitian operator"""
struct SHermitianOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SHermitianOperator(name) = SHermitianOperator(name, qubit_basis)

ishermitian(::SHermitianOperator) = true
isunitary(::SHermitianOperator) = false

"""Symbolic unitary operator"""
struct SUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SUnitaryOperator(name) = SUnitaryOperator(name, qubit_basis)

ishermitian(::SUnitaryOperator) = false
isunitary(::SUnitaryOperator) = true

"""Symbolic Hermitian and unitary operator"""
struct SHermitianUnitaryOperator <: Symbolic{AbstractOperator}
    name::Symbol
    basis::Basis
end
SHermitianUnitaryOperator(name) = SHermitianUnitaryOperator(name, qubit_basis)

ishermitian(::SHermitianUnitaryOperator) = true
isunitary(::SHermitianUnitaryOperator) = true

"""Symbolic superoperator"""
struct SSuperOperator <: Symbolic{AbstractSuperOperator}
    name::Symbol
    basis::Basis
end
SSuperOperator(name) = SSuperOperator(name, qubit_basis)
macro superop(name, basis)
    :($(esc(name)) = SSuperOperator($(Expr(:quote, name)), $(basis)))
end
macro superop(name)
    :($(esc(name)) = SSuperOperator($(Expr(:quote, name))))
end
ishermitian(x::SSuperOperator) = false
isunitary(x::SSuperOperator) = false

const SymQ = Union{SKet,SBra,SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator,SSuperOperator}
isexpr(::SymQ) = false
metadata(::SymQ) = nothing
symbollabel(x::SymQ) = x.name
basis(x::SymQ) = x.basis

Base.show(io::IO, x::SKet) = print(io, "|$(symbollabel(x))⟩")
Base.show(io::IO, x::SBra) = print(io, "⟨$(symbollabel(x))|")
Base.show(io::IO, x::Union{SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator,SSuperOperator}) = print(io, "$(symbollabel(x))")
Base.show(io::IO, x::SymQObj) = print(io, symbollabel(x)) # fallback that probably is not great

struct SZero{T<:QObj} <: Symbolic{T} end

"""Symbolic zero bra"""
const SZeroBra = SZero{AbstractBra}

"""Symbolic zero ket"""
const SZeroKet = SZero{AbstractKet}

"""Symbolic zero operator"""
const SZeroOperator = SZero{AbstractOperator}

isexpr(::SZero) = false
metadata(::SZero) = nothing
symbollabel(x::SZero) =  "𝟎"
basis(x::SZero) = nothing

Base.show(io::IO, x::SZero) = print(io, symbollabel(x))
Base.iszero(x::SymQObj) = isa(x, SZero)
