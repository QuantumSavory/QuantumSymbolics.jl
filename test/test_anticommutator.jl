using QuantumSymbolics
using Test

A = SOperator(:A, SpinBasis(1//2))
B = SOperator(:B, SpinBasis(1//2))

@testset "symbolic anticommutator tests" begin
    @test isequal(anticommutator(2*A, B), anticommutator(A, 2*B)) && isequal(2*anticommutator(A, B), anticommutator(2*A, B)) && isequal(2*anticommutator(A, B), anticommutator(2*A, B))
end

@testset "anticommutator Pauli tests" begin
    @test isequal(anticommutator(X, X), 2*I)
    @test isequal(anticommutator(Y, Y), 2*I)
    @test isequal(anticommutator(Z, Z), 2*I)
    @test isequal(anticommutator(X, Y), 0)
    @test isequal(anticommutator(Y, X), 0)
    @test isequal(anticommutator(Y, Z), 0)
    @test isequal(anticommutator(Z, Y), 0)
    @test isequal(anticommutator(Z, X), 0)
    @test isequal(anticommutator(X, Z), 0)
end