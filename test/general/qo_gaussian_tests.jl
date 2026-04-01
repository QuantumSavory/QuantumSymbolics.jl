@testitem "Test qo gaussian" begin
    using LinearAlgebra: diagm
    using QuantumOptics
    using QuantumSymbolics

    samestate(ket1, ket2; atol=1e-10) = isapprox(dm(ket1), dm(ket2); atol=atol, rtol=0)

    function two_mode_ops(cutoff)
        mode_basis = FockBasis(cutoff)
        basis = mode_basis^2
        return (
            basis = basis,
            vacuum = fockstate(mode_basis, 0) ⊗ fockstate(mode_basis, 0),
            a1 = embed(basis, 1, destroy(mode_basis)),
            a2 = embed(basis, 2, destroy(mode_basis)),
            ad1 = embed(basis, 1, create(mode_basis)),
            ad2 = embed(basis, 2, create(mode_basis)),
        )
    end

    @testset "Single-mode Gaussian objects" begin
        repr = QuantumOpticsRepr(10)
        basis = FockBasis(repr.cutoff)
        α = 0.2 - 0.1im
        θ = 0.3
        n̄ = 1.2

        thermal = express(BosonicThermalState(n̄), repr)
        weights = (n̄ / (n̄ + 1)) .^ collect(basis.offset:basis.N)
        expected_thermal = normalize(DenseOperator(basis, diagm(0 => weights)))

        @test thermal ≈ expected_thermal
        @test express(PhaseShiftOp(θ), repr) ≈ exp(-im * θ * dense(number(basis)))
        @test samestate(
            express(PhaseShiftOp(θ) * CoherentState(α), repr),
            coherentstate(basis, α * exp(-im * θ)),
        )
        @test express(PhaseShiftOp(θ) * BosonicThermalState(n̄) * dagger(PhaseShiftOp(θ)), repr) ≈ thermal
    end

    @testset "Two-mode Gaussian objects" begin
        repr = QuantumOpticsRepr(8)
        ops = two_mode_ops(repr.cutoff)
        z = 0.17 * exp(-0.3im)
        τ = 0.35

        twosqueeze = exp(dense(conj(z) * ops.a1 * ops.a2 - z * ops.ad1 * ops.ad2))
        beamsplitter = exp(asin(sqrt(τ)) * dense(ops.ad1 * ops.a2 - ops.a1 * ops.ad2))

        @test express(TwoSqueezeOp(z), repr) ≈ twosqueeze
        @test samestate(express(TwoSqueezedState(z), repr), twosqueeze * ops.vacuum)
        @test samestate(express(TwoSqueezeOp(z) * (vac ⊗ vac), repr), express(TwoSqueezedState(z), repr))

        @test express(BeamSplitterOp(τ), repr) ≈ beamsplitter
        @test samestate(
            express(BeamSplitterOp(τ) * (CoherentState(0.1 + 0.2im) ⊗ vac), repr),
            beamsplitter * express(CoherentState(0.1 + 0.2im) ⊗ vac, repr),
        )
    end
end
