using QuantumSymbolics
using Test

@bra b₁; @bra b₂;
@ket k₁; @ket k₂;
@op A; @op B; @op C;

@testset "trace tests" begin
    @test isequal(tr(2*A), 2*tr(A))
    @test isequal(tr(A+B), tr(A)+tr(B))
    @test isequal(tr(k₁*b₁), b₁*k₁)
    @test isequal(tr(commutator(A, B)), 0)
    @test isequal(tr((⊗)(A, B, C)), tr(A)*tr(B)*tr(C))
end
