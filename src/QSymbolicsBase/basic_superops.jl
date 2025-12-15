##
# Superoperator representations
##

"""Kraus representation of a quantum channel

```jldoctest
julia> @op A₁; @op A₂; @op A₃;

julia> K = kraus(A₁, A₂, A₃)
𝒦(A₁,A₂,A₃)

julia> @op ρ;

julia> K*ρ
A₁ρA₁†+A₂ρA₂†+A₃ρA₃†
```
"""
@withmetadata struct KrausRepr <: QSymbolic{AbstractSuperOperator}
    krausops
end
isexpr(::KrausRepr) = true
iscall(::KrausRepr) = true
arguments(x::KrausRepr) = x.krausops
operation(x::KrausRepr) = kraus
head(x::KrausRepr) = :kraus
children(x::KrausRepr) = [:kraus; x.krausops]
kraus(xs::QSymbolic{AbstractOperator}...) = KrausRepr(collect(xs))
basis(x::KrausRepr) = basis(first(x.krausops))
Base.:(*)(sop::KrausRepr, op::QSymbolic{AbstractOperator}) = (+)((i*op*dagger(i) for i in sop.krausops)...)
Base.:(*)(sop::KrausRepr, k::QSymbolic{AbstractKet}) = (+)((i*SProjector(k)*dagger(i) for i in sop.krausops)...)
Base.:(*)(sop::KrausRepr, k::SZeroOperator) = SZeroOperator()
Base.:(*)(sop::KrausRepr, k::SZeroKet) = SZeroOperator()
Base.show(io::IO, x::KrausRepr) = print(io, "𝒦("*join([symbollabel(i) for i in x.krausops], ",")*")")

##
# Superoperator operations
##

"""Symbolic application of a superoperator on an operator

```jldoctest
julia> @op A; @superop S;

julia> S*A
S[A]
```
"""
@withmetadata struct SSuperOpApply <: QSymbolic{AbstractOperator}
    sop
    op
end
isexpr(::SSuperOpApply) = true
iscall(::SSuperOpApply) = true
arguments(x::SSuperOpApply) = [x.sop,x.op]
operation(x::SSuperOpApply) = *
head(x::SSuperOpApply) = :*
children(x::SSuperOpApply) = [:*,x.sop,x.op]
Base.:(*)(sop::QSymbolic{AbstractSuperOperator}, op::QSymbolic{AbstractOperator}) = SSuperOpApply(sop,op)
Base.:(*)(sop::QSymbolic{AbstractSuperOperator}, op::SZeroOperator) = SZeroOperator()
Base.:(*)(sop::QSymbolic{AbstractSuperOperator}, k::QSymbolic{AbstractKet}) = SSuperOpApply(sop,SProjector(k))
Base.:(*)(sop::QSymbolic{AbstractSuperOperator}, k::SZeroKet) = SZeroOperator()
Base.show(io::IO, x::SSuperOpApply) = print(io, "$(x.sop)[$(x.op)]")
basis(x::SSuperOpApply) = basis(x.op)
