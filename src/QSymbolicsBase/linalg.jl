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
julia> @op A; @op B;

julia> ptrace(A, 1)
tr1(A)

julia> ptrace(A⊗B, 1)
(tr(A))B

julia> @ket k; @bra b;

julia> pure_state = A ⊗ (k*b)
(A⊗|k⟩⟨b|)

julia> ptrace(pure_state, 1)
(tr(A))|k⟩⟨b|

julia> ptrace(pure_state, 2)
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
function ptrace(x::Symbolic{AbstractOperator}, s) 
    if isa(basis(x), QuantumInterface.CompositeBasis)
        SPartialTrace(x, s)
    else
        throw(ArgumentError("cannot take partial trace of a single quantum system"))
    end
end
function ptrace(x::STensorOperator, s)
    terms = arguments(x)
    newterms = []
    if isa(basis(terms[s]), QuantumInterface.CompositeBasis)
        SPartial(x, s)
    else 
        sys_op = terms[s]
        new_terms = deleteat!(copy(terms), s)
        isone(length(new_terms)) ? tr(sys_op)*first(new_terms) : tr(sys_op)*STensorOperator(new_terms)
    end
end
function ptrace(x::SAddOperator, s)
    terms = arguments(x)
    add_terms = []
    for i in terms
        if isexpr(i) && operation(i) === ⊗
            isa(i, SScaledOperator) ? prod_terms = arguments(i.obj) : prod_terms = arguments(i)
            sys_op = prod_terms[s]
            new_terms = deleteat!(copy(prod_terms), s)
            isone(length(new_terms)) ? push!(add_terms, tr(sys_op)*first(new_terms)) : push!(add_terms, tr(sys_op)*STensorOperator(new_terms))
        else
            throw(ArgumentError("cannot take partial trace of a single quantum system"))
        end
    end
    (+)(add_terms...)
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