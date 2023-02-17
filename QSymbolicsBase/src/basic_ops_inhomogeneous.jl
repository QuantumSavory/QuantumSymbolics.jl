@withmetadata struct SApplyKet <: Symbolic{AbstractKet}
    op
    ket
end
istree(::SApplyKet) = true
arguments(x::SApplyKet) = [x.op,x.ket]
operation(x::SApplyKet) = *
Base.:(*)(op::Symbolic{AbstractOperator}, k::Symbolic{AbstractKet}) = SApplyKet(op,k)
Base.show(io::IO, x::SApplyKet) = begin print(io, x.op); print(io, x.ket) end
basis(x::SApplyKet) = basis(x.ket)

@withmetadata struct SApplyBra <: Symbolic{AbstractBra}
    bra
    op
end
istree(::SApplyBra) = true
arguments(x::SApplyBra) = [x.bra,x.op]
operation(x::SApplyBra) = *
Base.:(*)(b::Symbolic{AbstractBra}, op::Symbolic{AbstractOperator}) = SApplyBra(b,op)
Base.show(io::IO, x::SApplyBra) = begin print(io, x.bra); print(io, x.op) end
basis(x::SApplyBra) = basis(x.bra)

@withmetadata struct SBraKet <: Symbolic{Complex}
    bra
    op
    ket
end
istree(::SBraKet) = true
arguments(x::SBraKet) = [x.bra,x.op,x.ket]
operation(x::SBraKet) = *
#Base.:(*)(b::Symbolic{Bra}, op::Symbolic{Operator}, k::Symbolic{Ket}) = SBraKet(b,op,k)
function Base.show(io::IO, x::SBraKet)
    if isnothing(x.op)
        print(io,string(x.bra)[1:end-1])
        print(io,x.ket)
    else
        print(io.x.bra)
        print(io.x.op)
        print(io.x.ket)
    end
end

@withmetadata struct SApplyOp <: Symbolic{AbstractOperator}
    sop
    op
end
istree(::SApplyOp) = true
arguments(x::SApplyOp) = [x.sop,x.op]
operation(x::SApplyOp) = *
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, op::Symbolic{AbstractOperator}) = SApplyOp(sop,op)
Base.:(*)(sop::Symbolic{AbstractSuperOperator}, k::Symbolic{AbstractKet}) = SApplyOp(sop,SProjector(k))
Base.show(io::IO, x::SApplyOp) = begin print(io, x.sop); print(io, x.op) end
basis(x::SApplyOp) = basis(x.op)

@withmetadata struct SApplyKetBra <: Symbolic{AbstractOperator}
    ket
    bra
end
istree(::SApplyKetBra) = true
arguments(x::SApplyKetBra) = [x.ket,x.bra]
operation(x::SApplyKetBra) = *
Base.:(*)(k::Symbolic{AbstractKet}, b::Symbolic{AbstractBra}) = SApplyKetBra(k,b)
Base.show(io::IO, x::SApplyKetBra) = begin print(io, x.ket); print(io, x.bra) end
basis(x::SApplyKetBra) = basis(x.op)