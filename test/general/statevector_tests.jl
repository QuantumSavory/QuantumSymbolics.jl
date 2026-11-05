using Test
using QuantumOpticsBase
using QuantumSymbolics

@testset "StateVectorRepr" begin
    for symbolic in (X1, Z1, X1 ⊗ Z1, X, X ⊗ Z)
        wrapped = express(symbolic, QuantumOpticsRepr())
        plain = express(symbolic, StateVectorRepr())

        @test plain == wrapped.data
        @test plain isa Union{AbstractVector{<:Complex},AbstractMatrix{<:Complex}}
    end

    for cutoff in (2, 4)
        wrapped = express(N, QuantumOpticsRepr(cutoff=cutoff))
        plain = express(N, StateVectorRepr(cutoff=cutoff))

        @test plain == wrapped.data
        @test size(plain) == (cutoff, cutoff)
    end
end
