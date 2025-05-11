@testitem "Fock" begin
    using Symbolics: Term
    state1 = FockState(1)
    state2 = FockState(2)
    cstate = CoherentState(im)
    phase1 = PhaseShiftOp(0)
    phase2 = PhaseShiftOp(pi)
    displace = DisplaceOp(im)
    squeezeop = SqueezeOp(pi)
    twosqueezeop = TwoSqueezeOp(pi)
    sstate = SqueezedState(pi)
    tsstate = EPRState(pi)

    @testset "ladder and number operators" begin
        @test isequal(qsimplify(Destroy*vac, rewriter=qsimplify_fock), SZeroKet())
        @test isequal(qsimplify(Create*state1, rewriter=qsimplify_fock), Term(sqrt, [2])*state2)
        @test isequal(qsimplify(Destroy*state2, rewriter=qsimplify_fock), Term(sqrt, [2])*state1)
        @test isequal(qsimplify(N*state2, rewriter=qsimplify_fock), 2*state2)
        @test isequal(qsimplify(Destroy*cstate, rewriter=qsimplify_fock), im*cstate)
    end

    @testset "Displacement and phase operators" begin
        @test isequal(qsimplify(phase1*cstate, rewriter=qsimplify_fock), CoherentState(im))
        @test isequal(qsimplify(dagger(phase2)*Destroy*phase2, rewriter=qsimplify_fock), Destroy*exp(-im*pi))
        @test isequal(qsimplify(phase2*Destroy*dagger(phase2), rewriter=qsimplify_fock), Destroy*exp(im*pi))
        @test isequal(qsimplify(dagger(displace)*Destroy*displace, rewriter=qsimplify_fock), Destroy + im*IdentityOp(inf_fock_basis))
        @test_broken isequal(qsimplify(dagger(displace)*Create*displace, rewriter=qsimplify_fock), Create - im*IdentityOp(inf_fock_basis))
        @test isequal(qsimplify(displace*vac, rewriter=qsimplify_fock), cstate)
    end

    @testset "Squeeze operators" begin
        @test isequal(qsimplify(squeezeop*vac, rewriter=qsimplify_fock), sstate)
        @test isequal(qsimplify(twosqueezeop*(vac ⊗ vac), rewriter=qsimplify_fock), tsstate)
    end
end