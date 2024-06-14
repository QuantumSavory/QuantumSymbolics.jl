using QuantumSymbolics
using Test

A = SOperator(:A, SpinBasis(1//2))
B = SOperator(:B, SpinBasis(1//2))

@testset "symbolic commutator tests" begin
    @test isequal(commutator(2*A, B), commutator(A, 2*B)) && isequal(2*commutator(A, B), commutator(2*A, B)) && isequal(commutator(A, 2*B), 2*commutator(A, B))
    @test commutator(A, A) == 0

    @test isequal(commutator(commutative(A), A), 0)
    @test isequal(commutator(A, commutative(A)), 0)
    @test isequal(commutator(commutative(A), commutative(A)), 0)
end

@testset "commutator Pauli tests" begin
    @test commutator(X, X) == 0 && commutator(Y, Y) == 0 && commutator(Z, Z) == 0
    @test isequal(commutator(X, Y), 2*im*Z)
    @test isequal(commutator(Y, X), -2*im*Z)
    @test isequal(commutator(Y, Z), 2*im*X)
    @test isequal(commutator(Z, Y), -2*im*X)
    @test isequal(commutator(Z, X), 2*im*Y)
    @test isequal(commutator(X, Z), -2*im*Y)
end