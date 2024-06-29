##
# Linear algebra operations on quantum objects.
##

"""Projector for a given ket

```jldoctest
julia> SProjector(X1⊗X2)
𝐏[|X₁⟩|X₂⟩]

julia> express(SProjector(X2))
Operator(dim=2x2)
  basis: Spin(1/2)
  0.5+0.0im  -0.5-0.0im
 -0.5+0.0im   0.5+0.0im
```"""
@withmetadata struct SProjector <: Symbolic{AbstractOperator}
    ket::Symbolic{AbstractKet} # TODO parameterize
end
isexpr(::SProjector) = true
iscall(::SProjector) = true
arguments(x::SProjector) = [x.ket]
operation(x::SProjector) = projector
head(x::SProjector) = :projector
children(x::SProjector) = [:projector,x.ket]
projector(x::Symbolic{AbstractKet}) = SProjector(x)
projector(x::SZeroKet) = SZeroOperator()
basis(x::SProjector) = basis(x.ket)
function Base.show(io::IO, x::SProjector)
    print(io,"𝐏[")
    print(io,x.ket)
    print(io,"]")
end

"""Dagger, i.e., adjoint of quantum objects (kets, bras, operators)

```jldoctest 
julia> @ket a; @op A;

julia> dagger(2*im*A*a)
0 - 2im|a⟩†A†

julia> @op B;

julia> dagger(A*B)
B†A†

julia> ℋ = SHermitianOperator(:ℋ); U = SUnitaryOperator(:U);

julia> dagger(ℋ)
ℋ

julia> dagger(U) 
U⁻¹
```
"""
@withmetadata struct SDagger{T<:QObj} <: Symbolic{T}
    obj
end
isexpr(::SDagger) = true
iscall(::SDagger) = true
arguments(x::SDagger) = [x.obj]
operation(x::SDagger) = dagger
head(x::SDagger) = :dagger
children(x::SDagger) = [:dagger, x.obj]
dagger(x::Symbolic{AbstractBra}) = SDagger{AbstractKet}(x)
dagger(x::Symbolic{AbstractKet}) = SDagger{AbstractBra}(x)
dagger(x::Symbolic{AbstractOperator}) = SDagger{AbstractOperator}(x)
dagger(x::SScaledKet) = SScaledBra(conj(x.coeff), dagger(x.obj))
dagger(x::SAdd) = (+)((dagger(i) for i in arguments(x))...)
dagger(x::SScaledBra) = SScaledKet(conj(x.coeff), dagger(x.obj))
dagger(x::SZeroOperator) = x
dagger(x::SHermitianOperator) = x
dagger(x::SHermitianUnitaryOperator) = x
dagger(x::SUnitaryOperator) = inv(x)
dagger(x::STensorBra) = STensorKet(collect(dagger(i) for i in x.terms))
dagger(x::STensorKet) = STensorBra(collect(dagger(i) for i in x.terms))
dagger(x::STensorOperator) = STensorOperator(collect(dagger(i) for i in x.terms))
dagger(x::SScaledOperator) = SScaledOperator(conj(x.coeff), dagger(x.obj))
dagger(x::SApplyKet) = dagger(x.ket)*dagger(x.op)
dagger(x::SApplyBra) = dagger(x.op)*dagger(x.bra)
dagger(x::SMulOperator) = SMulOperator(collect(dagger(i) for i in reverse(x.terms)))
dagger(x::SBraKet) = SBraKet(dagger(x.ket), dagger(x.bra))
dagger(x::SOuterKetBra) = SOuterKetBra(dagger(x.bra), dagger(x.ket))
dagger(x::SDagger) = x.obj
basis(x::SDagger) = basis(x.obj)
function Base.show(io::IO, x::SDagger)
    print(io,x.obj)
    print(io,"†")
end

"""Inverse Operator

```jldoctest
julia> @op A;

julia> inv(A)
A⁻¹

julia> inv(A)*A
𝕀
```
"""
@withmetadata struct SInvOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SInvOperator) = true
iscall(::SInvOperator) = true
arguments(x::SInvOperator) = [x.op]
operation(x::SInvOperator) = inv
head(x::SInvOperator) = :inv
children(x::SInvOperator) = [:inv, x.op]
basis(x::SInvOperator) = basis(x.op)
Base.show(io::IO, x::SInvOperator) = print(io, "$(x.op)⁻¹")
Base.:(*)(invop::SInvOperator, op::SOperator) = isequal(invop.op, op) ? IdentityOp(basis(op)) : SMulOperator(invop, op)
Base.:(*)(op::SOperator, invop::SInvOperator) = isequal(op, invop.op) ? IdentityOp(basis(op)) : SMulOperator(op, invop)
inv(x::Symbolic{AbstractOperator}) = SInvOperator(x)