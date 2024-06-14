using QuantumSymbolics
using QuantumInterface: AbstractOperator
using Test

b₁ = SBra(:b₁, SpinBasis(1//2))
b₂ = SBra(:b₂, SpinBasis(1//2))
k₁ = SKet(:k₁, SpinBasis(1//2))
k₂ = SKet(:k₂, SpinBasis(1//2))

A = SOperator(:A, SpinBasis(1//2))
B = SOperator(:B, SpinBasis(1//2))
C = SOperator(:C, SpinBasis(1//2))

@testset "symbolic dagger tests" begin
    @test isequal(dagger(k₁), SBra(:k₁, SpinBasis(1//2)))
    @test isequal(dagger(im*k₁), -im*SBra(:k₁, SpinBasis(1//2)))
    @test isequal(dagger(k₁+k₂), dagger(k₁)+dagger(k₂))
    @test isequal(dagger(b₁), SKet(:b₁, SpinBasis(1//2)))
    @test isequal(dagger(im*b₁), -im*SKet(:b₁, SpinBasis(1//2)))
    @test isequal(dagger(b₁+b₂), dagger(b₁)+dagger(b₂))
    @test isequal(dagger(A+B), dagger(A) + dagger(B))
    @test isequal(dagger(hermitian(A)), hermitian(A))
    @test isequal(dagger(unitary(A)), inverse(unitary(A)))
    @test isequal(dagger(b₁⊗b₂), dagger(b₁)⊗dagger(b₂))
    @test isequal(dagger(k₁⊗k₂), dagger(k₁)⊗dagger(k₂))
    @test isequal(dagger(A⊗B), dagger(A)⊗dagger(B))
    @test isequal(dagger(im*A), -im*dagger(A))
    @test isequal(dagger(A*k₁), dagger(k₁)*dagger(A))
    @test isequal(dagger(b₁*A), dagger(A)*dagger(b₁))
    @test isequal(dagger(A*B*C), dagger(C)*dagger(B)*dagger(A))
    @test isequal(dagger(b₁*k₁), dagger(k₁)*dagger(b₁))
    @test isequal(dagger(k₁*b₁), dagger(b₁)*  dagger(k₁))
    @test isequal(dagger(dagger(A)), A)
    @test isequal(dagger(dagger(A)), A)
end