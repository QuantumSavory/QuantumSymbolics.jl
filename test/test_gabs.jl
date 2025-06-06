@testitem "Gabs objects" begin
    using QuantumSymbolics
    using Gabs

    α = rand(ComplexF64)
    r, θ, τ = rand(Float64), rand(Float64), rand(Float64)
    n̄ = rand(1:10)

    for basis in [QuadBlockBasis, QuadPairBasis]
        @testset "Gaussian states - $(basis)" begin
            @test express(vac, GabsRepr(basis)) ≈ vacuumstate(basis(1))
            @test express(CoherentState(α), GabsRepr(basis)) ≈ coherentstate(basis(1), α)
            @test express(SqueezedState(r*exp(im*θ)), GabsRepr(basis)) ≈ squeezedstate(basis(1), r, θ)
            @test express(TwoSqueezedState(r*exp(im*θ)), GabsRepr(basis)) ≈ eprstate(basis(2), r, θ)
            @test express(BosonicThermalState(n̄), GabsRepr(basis)) ≈ thermalstate(basis(1), n̄)
        end

        @testset "Gaussian unitaries - $(basis)" begin
            @test express(PhaseShiftOp(θ), GabsRepr(basis)) ≈ phaseshift(basis(1), θ)
            @test express(DisplaceOp(α), GabsRepr(basis)) ≈ displace(basis(1), α)
            @test express(SqueezeOp(r*exp(im*θ)), GabsRepr(basis)) ≈ squeeze(basis(1), r, θ)
            @test express(TwoSqueezeOp(r*exp(im*θ)), GabsRepr(basis)) ≈ twosqueeze(basis(2), r, θ)
            @test express(BeamSplitterOp(τ), GabsRepr(basis)) ≈ beamsplitter(basis(2), τ)
        end

        @testset "Linear algebra operations" begin
            @test express(CoherentState(α) ⊗ TwoSqueezedState(r*exp(im*θ)) ⊗ vac, GabsRepr(basis)) ≈ coherentstate(basis(1), α) ⊗ eprstate(basis(2), r, θ) ⊗ vacuumstate(basis(1))
            @test express(DisplaceOp(α) * vac, GabsRepr(basis)) ≈ coherentstate(basis(1), α)
            @test express(DisplaceOp(α) ⊗ SqueezeOp(r*exp(im*θ)) * (vac ⊗ vac), GabsRepr(basis)) ≈ coherentstate(basis(1), α) ⊗ squeezedstate(basis(1), r, θ)
            @test_broken express(ptrace(DisplaceOp(α) ⊗ PhaseShiftOp(θ) ⊗ BeamSplitterOp(τ), [2, 3]), GabsRepr(basis)) ≈ ptrace(displace(basis(1), α) ⊗ phaseshift(basis(1), θ) ⊗ beamsplitter(basis(2), τ), [2, 3])
        end
    end
end