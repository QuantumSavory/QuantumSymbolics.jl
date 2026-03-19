@testitem "Gabs and QuantumOptics Gaussian interop" begin
    using Gabs
    using QuantumOptics
    using QuantumSymbolics

    samestate(ket1, ket2; atol=1e-10) = isapprox(dm(ket1), dm(ket2); atol=atol, rtol=0)

    express_via_gabs(state, repr, basis) = express(express(state, GabsRepr(basis)), repr)

    function act_via_gabs(op, state, repr, basis)
        grepr = GabsRepr(basis)
        express(express(op, grepr) * express(state, grepr), repr)
    end

    direct_action(op, state, repr) = express(op, repr) * express(state, repr)
    symbolic_action(op, state, repr) = express(op * state, repr)

    @testset "Pure-state conversions" begin
        repr = QuantumOpticsRepr(14)
        α = 0.21 - 0.13im
        z = 0.17 * exp(-0.3im)

        direct_vacuum = express(vac, repr)
        direct_product = express(CoherentState(α) ⊗ vac, repr)
        direct_twomode_squeezed = express(TwoSqueezedState(z), repr)

        for basis in (QuadPairBasis, QuadBlockBasis)
            @test samestate(express_via_gabs(vac, repr, basis), direct_vacuum)
            @test samestate(express_via_gabs(CoherentState(α) ⊗ vac, repr, basis), direct_product)
            @test samestate(
                express_via_gabs(TwoSqueezedState(z), repr, basis),
                direct_twomode_squeezed;
                atol=1e-9,
            )
        end

        pair_state = express_via_gabs(TwoSqueezedState(z), repr, QuadPairBasis)
        block_state = express_via_gabs(TwoSqueezedState(z), repr, QuadBlockBasis)
        @test samestate(pair_state, block_state; atol=1e-9)
    end

    @testset "Simple edge cases" begin
        repr = QuantumOpticsRepr(14)
        α = 0.21 - 0.13im
        z = 0.0 + 0.2im
        πf = float(pi)

        for basis in (QuadPairBasis, QuadBlockBasis)
            @test samestate(
                act_via_gabs(PhaseShiftOp(0.0), CoherentState(α), repr, basis),
                express(CoherentState(α), repr),
            )
            @test samestate(
                act_via_gabs(PhaseShiftOp(πf), CoherentState(α), repr, basis),
                express(CoherentState(-α), repr),
            )

            @test samestate(
                act_via_gabs(BeamSplitterOp(0.0), CoherentState(α) ⊗ vac, repr, basis),
                express(CoherentState(α) ⊗ vac, repr),
            )
            @test samestate(
                act_via_gabs(BeamSplitterOp(1.0), CoherentState(α) ⊗ vac, repr, basis),
                express(vac ⊗ CoherentState(-α), repr),
            )

            @test samestate(
                act_via_gabs(TwoSqueezeOp(0.0 + 0.0im), vac ⊗ vac, repr, basis),
                express(vac ⊗ vac, repr),
            )
            @test samestate(
                act_via_gabs(TwoSqueezeOp(z), vac ⊗ vac, repr, basis),
                express(TwoSqueezedState(z), repr),
            )
        end
    end

    @testset "Operator actions agree across paths" begin
        repr = QuantumOpticsRepr(14)
        α = 0.21 - 0.13im
        z = 0.17 * exp(-0.3im)

        phase = PhaseShiftOp(pi / 2)
        beamsplitter = BeamSplitterOp(0.35)
        twosqueeze = TwoSqueezeOp(z)

        phase_state = CoherentState(α)
        twomode_state = CoherentState(α) ⊗ vac
        vacuum_pair = vac ⊗ vac

        phase_direct = direct_action(phase, phase_state, repr)
        phase_symbolic = symbolic_action(phase, phase_state, repr)
        @test samestate(phase_symbolic, phase_direct)

        beamsplitter_direct = direct_action(beamsplitter, twomode_state, repr)
        beamsplitter_symbolic = symbolic_action(beamsplitter, twomode_state, repr)
        @test samestate(beamsplitter_symbolic, beamsplitter_direct)

        twosqueeze_direct = direct_action(twosqueeze, twomode_state, repr)
        twosqueeze_symbolic = symbolic_action(twosqueeze, twomode_state, repr)
        @test samestate(twosqueeze_symbolic, twosqueeze_direct; atol=1e-9)

        twosqueeze_vacuum_direct = direct_action(twosqueeze, vacuum_pair, repr)
        twosqueeze_vacuum_symbolic = symbolic_action(twosqueeze, vacuum_pair, repr)
        twosqueeze_state = express(TwoSqueezedState(z), repr)
        @test samestate(twosqueeze_vacuum_symbolic, twosqueeze_vacuum_direct)
        @test samestate(twosqueeze_vacuum_symbolic, twosqueeze_state)

        for basis in (QuadPairBasis, QuadBlockBasis)
            phase_via_gabs = act_via_gabs(phase, phase_state, repr, basis)
            @test samestate(phase_via_gabs, phase_direct)

            beamsplitter_via_gabs = act_via_gabs(beamsplitter, twomode_state, repr, basis)
            @test samestate(beamsplitter_via_gabs, beamsplitter_direct)

            twosqueeze_via_gabs = act_via_gabs(twosqueeze, twomode_state, repr, basis)
            @test samestate(twosqueeze_via_gabs, twosqueeze_direct; atol=1e-9)

            twosqueeze_vacuum_via_gabs = act_via_gabs(twosqueeze, vacuum_pair, repr, basis)
            @test samestate(twosqueeze_vacuum_via_gabs, twosqueeze_state; atol=1e-9)
        end

        pair_state = act_via_gabs(twosqueeze, twomode_state, repr, QuadPairBasis)
        block_state = act_via_gabs(twosqueeze, twomode_state, repr, QuadBlockBasis)
        @test samestate(pair_state, block_state; atol=1e-9)
    end
end
