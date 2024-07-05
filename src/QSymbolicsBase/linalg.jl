##
# Linear algebra operations on quantum objects.
##

"""Symbolic commutator of two operators. 

```jldoctest
julia> @op A; @op B;

julia> commutator(A, B)
[A,B]

julia> commutator(A, A)
𝟎
```
"""
@withmetadata struct SCommutator <: Symbolic{AbstractOperator}
    op1
    op2
end
isexpr(::SCommutator) = true
iscall(::SCommutator) = true
arguments(x::SCommutator) = [x.op1, x.op2]
operation(x::SCommutator) = commutator
head(x::SCommutator) = :commutator
children(x::SCommutator) = [:commutator, x.op1, x.op2]
function commutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator})
    coeff, cleanterms = prefactorscalings([o1 o2])
    cleanterms[1] === cleanterms[2] ? SZeroOperator() : coeff * SCommutator(cleanterms...)   
end
commutator(o1::SZeroOperator, o2::Symbolic{AbstractOperator}) = SZeroOperator()
commutator(o1::Symbolic{AbstractOperator}, o2::SZeroOperator) = SZeroOperator()
commutator(o1::SZeroOperator, o2::SZeroOperator) = SZeroOperator()
Base.show(io::IO, x::SCommutator) = print(io, "[$(x.op1),$(x.op2)]")
basis(x::SCommutator) = basis(x.op1)

"""Symbolic anticommutator of two operators.

```jldoctest
julia> @op A; @op B;

julia> anticommutator(A, B)
{A,B}
```
"""
@withmetadata struct SAnticommutator <: Symbolic{AbstractOperator}
    op1
    op2
end
isexpr(::SAnticommutator) = true
iscall(::SAnticommutator) = true
arguments(x::SAnticommutator) = [x.op1, x.op2]
operation(x::SAnticommutator) = anticommutator
head(x::SAnticommutator) = :anticommutator
children(x::SAnticommutator) = [:anticommutator, x.op1, x.op2]
function anticommutator(o1::Symbolic{AbstractOperator}, o2::Symbolic{AbstractOperator})
    coeff, cleanterms = prefactorscalings([o1 o2])
    coeff * SAnticommutator(cleanterms...)
end
anticommutator(o1::SZeroOperator, o2::Symbolic{AbstractOperator}) = SZeroOperator()
anticommutator(o1::Symbolic{AbstractOperator}, o2::SZeroOperator) = SZeroOperator()
anticommutator(o1::SZeroOperator, o2::SZeroOperator) = SZeroOperator()
Base.show(io::IO, x::SAnticommutator) = print(io, "{$(x.op1),$(x.op2)}")
basis(x::SAnticommutator) = basis(x.op1)

"""Complex conjugate of quantum objects (kets, bras, operators).

```jldoctest 
julia> @op A; @ket k;

julia> conj(A)
Aˣ

julia> conj(k)
|k⟩ˣ
```
"""
@withmetadata struct SConjugate{T<:QObj} <: Symbolic{T}
    obj
end
isexpr(::SConjugate) = true
iscall(::SConjugate) = true
arguments(x::SConjugate) = [x.obj]
operation(x::SConjugate) = conj
head(x::SConjugate) = :conj
children(x::SConjugate) = [:conj, x.obj]
conj(x::Symbolic{T}) where {T<:QObj} = SConjugate{T}(x)
conj(x::SZero) = x
conj(x::SConjugate) = x.obj
basis(x::SConjugate) = basis(x.obj)
function Base.show(io::IO, x::SConjugate)
    print(io,x.obj)
    print(io,"ˣ")
end

"""Projector for a given ket.

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

"""Transpose of quantum objects (kets, bras, operators).

```jldoctest 
julia> @op A; @op B; @ket k;

julia> transpose(A)
Aᵀ

julia> transpose(A+B)
(Aᵀ+Bᵀ)

julia> transpose(k)
|k⟩ᵀ
```
"""
@withmetadata struct STranspose{T<:QObj} <: Symbolic{T}
    obj
end
isexpr(::STranspose) = true
iscall(::STranspose) = true
arguments(x::STranspose) = [x.obj]
operation(x::STranspose) = transpose
head(x::STranspose) = :transpose
children(x::STranspose) = [:transpose, x.obj]
transpose(x::Symbolic{AbstractOperator}) = STranspose{AbstractOperator}(x)
transpose(x::Symbolic{AbstractKet}) = STranspose{AbstractBra}(x)
transpose(x::Symbolic{AbstractBra}) = STranspose{AbstractKet}(x)
transpose(x::SScaled) = x.coeff*transpose(x.obj)
transpose(x::SAdd) = (+)((transpose(i) for i in arguments(x))...)
transpose(x::SMulOperator) = (*)((transpose(i) for i in reverse(x.terms))...)
transpose(x::STensor) = (⊗)((transpose(i) for i in x.terms)...)
transpose(x::SZeroOperator) = x
transpose(x::STranspose) = x.obj
basis(x::STranspose) = basis(x.obj)
function Base.show(io::IO, x::STranspose)
    print(io,x.obj)
    print(io,"ᵀ")
end

"""Dagger, i.e., adjoint of quantum objects (kets, bras, operators).

```jldoctest 
julia> @ket a; @op A;

julia> dagger(2*im*A*a)
(0 - 2im)|a⟩†A†

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
dagger(x::SScaled) = conj(x.coeff)*dagger(x.obj)
dagger(x::SAdd) = (+)((dagger(i) for i in arguments(x))...)
dagger(x::SMulOperator) = (*)((dagger(i) for i in reverse(x.terms))...)
dagger(x::STensor) = (⊗)((dagger(i) for i in x.terms)...)
dagger(x::SZeroOperator) = x
dagger(x::SHermitianOperator) = x
dagger(x::SHermitianUnitaryOperator) = x
dagger(x::SUnitaryOperator) = inv(x)
dagger(x::SApplyKet) = dagger(x.ket)*dagger(x.op)
dagger(x::SApplyBra) = dagger(x.op)*dagger(x.bra)
dagger(x::SBraKet) = dagger(x.ket)*dagger(x.bra)
dagger(x::SOuterKetBra) = dagger(x.bra)*dagger(x.ket)
dagger(x::SDagger) = x.obj
basis(x::SDagger) = basis(x.obj)
function Base.show(io::IO, x::SDagger)
    print(io,x.obj)
    print(io,"†")
end

"""Inverse of an operator.

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

"""Exponential of a symbolic operator.

```jldoctest
julia> @op A; @op B;

julia> exp(A)
exp(A)
```
"""
@withmetadata struct SExpOperator <: Symbolic{AbstractOperator}
    op::Symbolic{AbstractOperator}
end
isexpr(::SExpOperator) = true
iscall(::SExpOperator) = true
arguments(x::SExpOperator) = [x.op]
operation(x::SExpOperator) = exp
head(x::SExpOperator) = :exp
children(x::SExpOperator) = [:exp, x.op]
basis(x::SExpOperator) = basis(x.op)
Base.show(io::IO, x::SExpOperator) = print(io, "exp($(x.op))") 
exp(x::Symbolic{AbstractOperator}) = SExpOperator(x)

"""Vectorization of a symbolic operator.

```jldoctest
julia> @op A; @op B;

julia> vec(A)
|A⟩⟩

julia> vec(A+B)
(|A⟩⟩+|B⟩⟩)
```
"""
@withmetadata struct SVec <: Symbolic{AbstractKet}
    op::Symbolic{AbstractOperator}
end
isexpr(::SVec) = true
iscall(::SVec) = true
arguments(x::SVec) = [x.op]
operation(x::SVec) = vec
head(x::SVec) = :vec
children(x::SVec) = [:vec, x.op]
basis(x::SVec) = (⊗)(fill(basis(x.op), length(basis(x.op)))...)
Base.show(io::IO, x::SVec) = print(io, "|$(x.op)⟩⟩")
vec(x::Symbolic{AbstractOperator}) = SVec(x)
vec(x::SScaled{AbstractOperator}) = x.coeff*vec(x.obj)
vec(x::SAdd{AbstractOperator}) = (+)((vec(i) for i in arguments(x))...)