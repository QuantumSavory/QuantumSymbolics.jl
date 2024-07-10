using QuantumSymbolics
using QuantumSymbolics: inf_fock_basis
using Test

state1 = FockState(1, inf_fock_basis)
state2 = FockState(2, inf_fock_basis)
cstate = ContinuousCoherentState(im, inf_fock_basis)
phase1 = PhaseShiftOp(0, inf_fock_basis)
phase2 = PhaseShiftOp(pi, inf_fock_basis)
displace = DisplacementOp(im, inf_fock_basis)

@testset "ladder and number operators" begin
    @test isequal(qsimplify(Destroy*vac, rewriter=qsimplify_fock), SZeroKet())
    @test isequal(qsimplify(Create*state1, rewriter=qsimplify_fock), sqrt(2)*state2)
    @test isequal(qsimplify(Destroy*state2, rewriter=qsimplify_fock), sqrt(2)*state1)
    @test isequal(qsimplify(N*state2, rewriter=qsimplify_fock), 2*state2)
    @test isequal(qsimplify(Destroy*cstate, rewriter=qsimplify_fock), im*cstate)
end

@testset "Displacement and phase operators" begin
    @test isequal(qsimplify(phase1*cstate, rewriter=qsimplify_fock), ContinuousCoherentState(im, inf_fock_basis))
    @test isequal(qsimplify(dagger(phase2)*Destroy*phase2, rewriter=qsimplify_fock), Destroy*exp(-im*pi))
    @test isequal(qsimplify(phase2*Destroy*dagger(phase2), rewriter=qsimplify_fock), Destroy*exp(im*pi))
    @test isequal(qsimplify(dagger(displace)*Destroy*displace, rewriter=qsimplify_fock), Destroy + im*IdentityOp(inf_fock_basis))
    @test isequal(qsimplify(dagger(displace)*Create*displace, rewriter=qsimplify_fock), Create - im*IdentityOp(inf_fock_basis))
    @test isequal(qsimplify(displace*vac, rewriter=qsimplify_fock), cstate)
end