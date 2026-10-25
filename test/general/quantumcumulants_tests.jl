using QuantumCumulants

@testset "QuantumCumulants Express Backend" begin
    # Basic operators
    X = express(σˣ, QuantumCumulantsRepr())
    @test X isa QuantumCumulants.Operator

    # Tensor products
    X⊗Y = express(σˣ⊗σʸ, QuantumCumulantsRepr())
    @test X⊗Y isa QuantumCumulants.Operator
    @test_throws DimensionMismatch express(σˣ⊗σʸ⊗σᶻ, QuantumCumulantsRepr())

    # Superoperators
    L = express(lindblad(σˣ), QuantumCumulantsRepr())
    @test L isa QuantumCumulants.SuperOperator

    # States
    ψ = express(Z1, QuantumCumulantsRepr())
    @test ψ isa QuantumCumulants.State
    @test_throws DimensionMismatch express(Z1⊗Z2, QuantumCumulantsRepr())

    # Tensor products of superoperators
    L⊗L = express(lindblad(σˣ)⊗lindblad(σʸ), QuantumCumulantsRepr())
    @test L⊗L isa QuantumCumulants.SuperOperator
    @test_throws DimensionMismatch express(lindblad(σˣ)⊗lindblad(σʸ)⊗lindblad(σᶻ), QuantumCumulantsRepr())

    # Error handling
    @test_throws ArgumentError express(σˣ, QuantumCumulantsRepr())
    @test_throws ArgumentError express(lindblad(σˣ), QuantumCumulantsRepr())
end