using QuantumCore: AbstractSuperOperator

abstract type AbstractLazySuperOperator{B1,B2} <: AbstractSuperOperator{B1,B2} end

# TODO split in LazyPre, LazyPost and LazyPrePost
struct LazyPrePost{B,DT} <: AbstractLazySuperOperator{Tuple{B,B},Tuple{B,B}}
    preop::Operator{B,B,DT}
    postop::Operator{B,B,DT}
end
function LazyPrePost(preop::T,postop::T) where {B,DT,T<:Operator{B,B,DT}}
    LazyPrePost{B,DT}(preop,postop)
end

struct LazySuperSum{B,F,T} <: AbstractLazySuperOperator{Tuple{B,B},Tuple{B,B}}
    basis::B
    factors::F
    sops::T
end

QuantumOpticsBase.basis(sop::LazyPrePost) = basis(sop.preop)
QuantumOpticsBase.basis(sop::LazySuperSum) = sop.basis
QuantumOpticsBase.embed(bl,br,index,op::LazyPrePost) = LazyPrePost(embed(bl,br,index,op.preop),embed(bl,br,index,op.postop))
function Base.:(*)(sop::LazyPrePost, op::Operator)
    # TODO do not create the spre and spost objects, do it without intermediaries, do it in place with buffers
    r = op
    r = spre(sop.preop)*r
    r = spost(sop.postop)*r
    r
end
Base.:(*)(l::LazyPrePost, r::LazyPrePost) = LazyPrePost(l.preop*r.preop, r.postop*l.postop)
Base.:(+)(ops::LazyPrePost...) = LazySuperSum(basis(first(ops)),fill(1,length(ops)),ops)
QuantumOpticsBase.embed(bl,br,index,op::LazySuperSum) = LazySuperSum(bl, op.factors, [embed(bl,br,index,o) for o in op.sops])
function Base.:(*)(ssop::LazySuperSum, op::Operator)
    res = zero(op)
    for (f,sop) in zip(ssop.factors,ssop.sops)
        res += f*(sop*op)
    end
    res
end
