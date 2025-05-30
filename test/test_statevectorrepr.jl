using Test
using QuantumSymbolics
using QuantumOptics
using QuantumSavory

@testset "StateVectorRepr Conversion Tests" begin
    # Test: Symbolic Ket (X1) conversion
    sym_X1_test = QuantumSavory.X1
    qo_X1_data = QuantumOptics.express(sym_X1_test, QuantumOptics.QuantumOpticsRepr()).data
    sv_X1_data = express(sym_X1_test, StateVectorRepr())
    @test sv_X1_data isa Vector{ComplexF64}
    @test isapprox(sv_X1_data, qo_X1_data)
    @test length(sv_X1_data) == 2

    # Test: Symbolic Operator (Z1) conversion
    sym_Z1_test = QuantumSavory.Z1
    qo_Z1_data = QuantumOptics.express(sym_Z1_test, QuantumOptics.QuantumOpticsRepr()).data
    sv_Z1_data = express(sym_Z1_test, StateVectorRepr())
    @test sv_Z1_data isa Matrix{ComplexF64}
    @test isapprox(sv_Z1_data, qo_Z1_data)
    @test size(sv_Z1_data) == (2, 2)

    # Test: Product operator (X1 * Y2) conversion
    sym_XY_test = QuantumSavory.X1 * QuantumSavory.Y2
    qo_XY_data = QuantumOptics.express(sym_XY_test, QuantumOptics.QuantumOpticsRepr()).data
    sv_XY_data = express(sym_XY_test, StateVectorRepr())
    @test sv_XY_data isa Matrix{ComplexF64}
    @test isapprox(sv_XY_data, qo_XY_data)
    @test size(sv_XY_data) == (4, 4)

    # Test: Bosonic operator (N) with custom cutoff
    sym_N_test = QuantumSavory.N
    qo_N_cutoff4_data = QuantumOptics.express(sym_N_test, QuantumOptics.QuantumOpticsRepr(cutoff=4)).data
    sv_N_cutoff4_data = express(sym_N_test, StateVectorRepr(cutoff=4))
    @test sv_N_cutoff4_data isa Matrix{ComplexF64}
    @test isapprox(sv_N_cutoff4_data, qo_N_cutoff4_data)
    @test size(sv_N_cutoff4_data) == (5, 5)
end
