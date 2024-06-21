using QuantumSymbolics
using QuantumInterface: AbstractOperator
using Test

@bra b₁; @bra b₂;
@ket k₁; @ket k₂;

@op A; @op B; @op C;
U = SUnitaryOperator(:U); ℋ = SHermitianOperator(:ℋ);

@testset "symbolic dagger tests" begin
    @test isequal(dagger(im*k₁), -im*dagger(k₁))
    @test isequal(dagger(k₁+k₂), dagger(k₁)+dagger(k₂))
    @test isequal(dagger(im*b₁), -im*dagger(b₁))
    @test isequal(dagger(b₁+b₂), dagger(b₁)+dagger(b₂))
    @test isequal(dagger(A+B), dagger(A) + dagger(B))
    @test isequal(dagger(ℋ), ℋ)
    @test isequal(dagger(U), inv(U))
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