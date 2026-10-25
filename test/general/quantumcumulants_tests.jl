using QuantumCumulants

@testset "QuantumCumulants Express Backend" begin
    # Basic operators
    X = express(σˣ, QuantumCumulantsRepr())
    @test X isa QuantumCumulants.Operator

    # Tensor products
    X⊗Y = express(σˣ⊗σʸ, QuantumCumulantsRepr())
    @test X⊗Y isa QuantumCumulants.Operator

    # Superoperators
    L = express(lindblad(σˣ), QuantumCumulantsRepr())
    @test L isa QuantumCumulants.SuperOperator

    # States
    ψ = express(Z1, QuantumCumulantsRepr())
    @test ψ isa QuantumCumulants.State

    # Tensor products of superoperators
    L⊗L = express(lindblad(σˣ)⊗lindblad(σʸ), QuantumCumulantsRepr())
    @test L⊗L isa QuantumCumulants.SuperOperator

    # Check state conversion doesn't throw
    @test_throws Nothing express(Z1⊗Z2, QuantumCumulantsRepr())
end