##
# Representations of CPTP maps
##

@withmetadata struct KrausRepr <: Symbolic{AbstractSuperOperator}
    name::Symbol
    basis::Basis
    krausops
end
isexpr(::KrausRepr) = true
iscall(::KrausRepr) = true
arguments(x::KrausRepr) = x.terms
operation(x::KrausRepr) = kraus
head(x::KrausRepr) = :kraus
children(x::KrausRepr) = [:kraus; x.terms]
kraus(n::Symbol, b::Basis, xs::Symbolic{AbstractOperator}...) = KrausRepr(n,b,collect(xs))
symbollabel(x::KrausRepr) = x.name
basis(x::KrausRepr) = x.basis
Base.show(io::IO, x::KrausRepr) = print(io, symbollabel(x))
