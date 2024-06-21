using QuantumSymbolics
using Test

@sop A; @sop B;

@testset "symbolic anticommutator tests" begin
    @test isequal(anticommutator(2*A, B), anticommutator(A, 2*B)) && isequal(2*anticommutator(A, B), anticommutator(2*A, B)) && isequal(2*anticommutator(A, B), anticommutator(2*A, B))
end

@testset "anticommutator Pauli tests" begin
    @test isequal(qsimplify(anticommutator(X, X), rewriter=qsimplify_anticommutator), 2*I)
    @test isequal(qsimplify(anticommutator(Y, Y), rewriter=qsimplify_anticommutator), 2*I)
    @test isequal(qsimplify(anticommutator(Z, Z), rewriter=qsimplify_anticommutator), 2*I)
    @test isequal(qsimplify(anticommutator(X, Y), rewriter=qsimplify_anticommutator), 0)
    @test isequal(qsimplify(anticommutator(Y, X), rewriter=qsimplify_anticommutator), 0)
    @test isequal(qsimplify(anticommutator(Y, Z), rewriter=qsimplify_anticommutator), 0)
    @test isequal(qsimplify(anticommutator(Z, Y), rewriter=qsimplify_anticommutator), 0)
    @test isequal(qsimplify(anticommutator(Z, X), rewriter=qsimplify_anticommutator), 0)
    @test isequal(qsimplify(anticommutator(X, Z), rewriter=qsimplify_anticommutator), 0)
end