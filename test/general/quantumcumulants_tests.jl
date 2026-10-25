using QuantumCumulants

@testset "QuantumCumulants Express Backend" begin
    @testset "Operators" begin
    X = express(σˣ, QuantumCumulantsRepr())
    @test X isa QuantumCumulants.Operator

    end

    @testset "Tensor Products" begin
    X⊗Y = express(σˣ⊗σʸ, QuantumCumulantsRepr())
    @test X⊗Y isa QuantumCumulants.Operator
    @test_throws DimensionMismatch express(σˣ⊗σʸ⊗σᶻ, QuantumCumulantsRepr())

    end

    @testset "SuperOperators" begin
    L = express(lindblad(σˣ), QuantumCumulantsRepr())
    @test L isa QuantumCumulants.SuperOperator

    end

    @testset "States" begin
    ψ = express(Z1, QuantumCumulantsRepr())
    @test ψ isa QuantumCumulants.State
    @test_throws DimensionMismatch express(Z1⊗Z2, QuantumCumulantsRepr())

    # Tensor products of superoperators
    L⊗L = express(lindblad(σˣ)⊗lindblad(σʸ), QuantumCumulantsRepr())
    @test L⊗L isa QuantumCumulants.SuperOperator
    @test_throws DimensionMismatch express(lindblad(σˣ)⊗lindblad(σʸ)⊗lindblad(σᶻ), QuantumCumulantsRepr())

    # Error handling
    
end