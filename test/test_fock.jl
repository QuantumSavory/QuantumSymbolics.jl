using QuantumSymbolics
using QuantumSymbolics: inf_fock_basis
using Test

state1 = FockState(1, inf_fock_basis)
state2 = FockState(2, inf_fock_basis)

@testset "ladder operators" begin
    @test isequal(qsimplify(Create*state1, rewriter=qsimplify_fock), sqrt(2)*state2)
end