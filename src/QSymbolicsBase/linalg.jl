##
# Linear algebra operations on quantum objects.
##

#TODO upstream to QuantumInterface
"""The commutator of two operators."""
function commutator end
"""The anticommutator of two operators."""
function anticommutator end

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
    if !(samebases(basis(o1),basis(o2)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([o1 o2])
        cleanterms[1] === cleanterms[2] ? SZeroOperator() : coeff * SCommutator(cleanterms...)
    end
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
    if !(samebases(basis(o1),basis(o2)))
        throw(IncompatibleBases())
    else
        coeff, cleanterms = prefactorscalings([o1 o2])
        coeff * SAnticommutator(cleanterms...)
    end
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
"""
    conj(x::Symbolic{AbstractKet})
    conj(x::Symbolic{AbstractBra})
    conj(x::Symbolic{AbstractOperator})
    conj(x::Symbolic{AbstractSuperOperator})

Symbolic complex conjugate operation. See also [`SConjugate`](@ref).
"""
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
julia> projector(X1⊗X2)
𝐏[|X₁⟩|X₂⟩]

julia> express(projector(X2))
Operator(dim=2x2)
  basis: Spin(1/2)
  0.5+0.0im  -0.5-0.0im
 -0.5+0.0im   0.5+0.0im
```
"""
@withmetadata struct SProjector <: Symbolic{AbstractOperator}
    ket::Symbolic{AbstractKet} # TODO parameterize
end
isexpr(::SProjector) = true
iscall(::SProjector) = true
arguments(x::SProjector) = [x.ket]
operation(x::SProjector) = projector
head(x::SProjector) = :projector
children(x::SProjector) = [:projector,x.ket]
"""
    projector(x::Symbolic{AbstractKet})

Symbolic projection operation. See also [`SProjector`](@ref).
"""
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
"""
    transpose(x::Symbolic{AbstractKet})
    transpose(x::Symbolic{AbstractBra})
    transpose(x::Symbolic{AbstractOperator})

Symbolic transpose operation. See also [`STranspose`](@ref).
"""
transpose(x::Symbolic{T}) where {T<:Union{AbstractKet,AbstractBra,AbstractOperator}} = STranspose{T}(x)
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
"""
    dagger(x::Symbolic{AbstractKet})

Symbolic adjoint operation. See also [`SDagger`](@ref).
"""
dagger(x::Symbolic{AbstractKet})= SDagger{AbstractBra}(x)
"""
    dagger(x::Symbolic{AbstractBra})

Symbolic adjoint operation. See also [`SDagger`](@ref).
"""
dagger(x::Symbolic{AbstractBra})= SDagger{AbstractKet}(x)
"""
    dagger(x::Symbolic{AbstractOperator})

Symbolic adjoint operation. See also [`SDagger`](@ref).
"""
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


"""Trace of an operator

```jldoctest
julia> @op A; @op B;

julia> tr(A)
tr(A)

julia> tr(commutator(A, B))
0

julia> @bra b; @ket k;

julia> tr(k*b)
⟨b||k⟩
```
"""
@withmetadata struct STrace <: Symbolic{Complex}
    op::Symbolic{AbstractOperator}
end
isexpr(::STrace) = true
iscall(::STrace) = true
arguments(x::STrace) = [x.op]
sorted_arguments(x::STrace) = arguments(x)
operation(x::STrace) = tr
head(x::STrace) = :tr
children(x::STrace) = [:tr, x.op]
Base.show(io::IO, x::STrace) = print(io, "tr($(x.op))")
"""
    tr(x::Symbolic{AbstractOperator})

Symbolic trace operation. See also [`STrace`](@ref).
"""
tr(x::Symbolic{AbstractOperator}) = STrace(x)
tr(x::SScaled{AbstractOperator}) = x.coeff*tr(x.obj)
tr(x::SAdd{AbstractOperator}) = (+)((tr(i) for i in arguments(x))...)
tr(x::SOuterKetBra) = x.bra*x.ket
tr(x::SCommutator) = 0
tr(x::STensorOperator) = (*)((tr(i) for i in arguments(x))...)
Base.hash(x::STrace, h::UInt) = hash((head(x), arguments(x)), h)
Base.isequal(x::STrace, y::STrace) = isequal(x.op, y.op)


"""Partial trace over system i of a composite quantum system

```jldoctest
julia> @op 𝒪 SpinBasis(1//2)⊗SpinBasis(1//2);

julia> op = ptrace(𝒪, 1)
tr1(𝒪)

julia> QuantumSymbolics.basis(op)
Spin(1/2)

julia> @op A; @op B;

julia> ptrace(A⊗B, 1)
(tr(A))B

julia> @ket k; @bra b;

julia> factorizable = A ⊗ (k*b)
(A⊗|k⟩⟨b|)

julia> ptrace(factorizable, 1)
(tr(A))|k⟩⟨b|

julia> ptrace(factorizable, 2)
(⟨b||k⟩)A

julia> mixed_state = (A⊗(k*b)) + ((k*b)⊗B)
((A⊗|k⟩⟨b|)+(|k⟩⟨b|⊗B))

julia> ptrace(mixed_state, 1)
((0 + ⟨b||k⟩)B+(tr(A))|k⟩⟨b|)

julia> ptrace(mixed_state, 2)
((0 + ⟨b||k⟩)A+(tr(B))|k⟩⟨b|)
```
"""
@withmetadata struct SPartialTrace <: Symbolic{AbstractOperator}
    obj
    sys::Int
end
isexpr(::SPartialTrace) = true
iscall(::SPartialTrace) = true
arguments(x::SPartialTrace) = [x.obj, x.sys]
operation(x::SPartialTrace) = ptrace
head(x::SPartialTrace) = :ptrace
children(x::SPartialTrace) = [:ptrace, x.obj, x.sys]
function basis(x::SPartialTrace)
    obj_bases = collect(basis(x.obj).bases)
    new_bases = deleteat!(copy(obj_bases), x.sys)
    tensor(new_bases...)
end
Base.show(io::IO, x::SPartialTrace) = print(io, "tr$(x.sys)($(x.obj))")
"""
    ptrace(x::Symbolic{AbstractOperator})

Symbolic partial trace operation. See also [`SPartialTrace`](@ref).
"""
function ptrace(x::Symbolic{AbstractOperator}, s)
    ex = isexpr(x) ? qexpand(x) : x
    if isa(ex, typeof(x))
        if isa(basis(x), CompositeBasis)
            SPartialTrace(x, s)
        elseif s==1
            tr(x)
        else
            throw(ArgumentError("cannot take partial trace of a single quantum system"))
        end
    else
        ptrace(ex, s)
    end
end
function ptrace(x::SAddOperator, s)
    add_terms = []
    if isa(basis(x), CompositeBasis)
        for i in arguments(x)
            if isexpr(i)
                if isa(i, SScaledOperator) && operation(i.obj) === ⊗  # scaled tensor product
                    prod_terms = arguments(i.obj)
                    coeff = i.coeff
                elseif operation(i) === ⊗  # tensor product
                    prod_terms = arguments(i)
                    coeff = 1
                else  # multiplication of operators with composite basis
                    return SPartialTrace(x,s)
                end
            else  # operator with composite basis
                return SPartialTrace(x,s)
            end
            if any(j -> isa(basis(j), CompositeBasis), prod_terms)  # tensor product of operators with composite bases
                return SPartialTrace(x,s)
            else  # tensor product without composite basis
                sys_op = coeff*prod_terms[s]
                new_terms = deleteat!(copy(prod_terms), s)
                trace = tr(sys_op)
                isone(length(new_terms)) ? push!(add_terms, trace*first(new_terms)) : push!(add_terms, trace*(⊗)(new_terms...))
            end
        end
        (+)(add_terms...)
    elseif s==1 # partial trace must be over the first system if sum does not have a composite basis
        tr(x)
    else
        throw(ArgumentError("cannot take partial trace of a single quantum system"))
    end
end
function ptrace(x::STensorOperator, s)
    ex = qexpand(x)
    if isa(ex, SAddOperator)
        ptrace(ex, s)
    else
        terms = arguments(ex)
        newterms = []
        if any(i -> isa(basis(i), CompositeBasis), terms)
            SPartialTrace(ex, s)
        else
            sys_op = terms[s]
            new_terms = deleteat!(copy(terms), s)
            isone(length(new_terms)) ? tr(sys_op)*first(new_terms) : tr(sys_op)*STensorOperator(new_terms)
        end
    end
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
"""
    inv(x::Symbolic{AbstractOperator})

Symbolic inverse of an operator. See also [`SInvOperator`](@ref).
"""
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
"""
    exp(x::Symbolic{AbstractOperator})

Symbolic exponential of an operator. See also [`SExpOperator`](@ref).
"""
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
"""
    vec(x::Symbolic{AbstractOperator})

Symbolic vector representation of an operator. See also [`SVec`](@ref).
"""
vec(x::Symbolic{AbstractOperator}) = SVec(x)
vec(x::SScaled{AbstractOperator}) = x.coeff*vec(x.obj)
vec(x::SAdd{AbstractOperator}) = (+)((vec(i) for i in arguments(x))...)
