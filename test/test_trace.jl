using QuantumSymbolics
using Test

@bra b₁; @bra b₂;
@ket k₁; @ket k₂;
@op A; @op B; @op C;

@testset "trace tests" begin
    @test_broken isequal(tr(2*A), 2*tr(A))
    @test_broken isequal(tr(A+B), tr(A)+tr(B))
    @test isequal(tr(k₁*b₁), b₁*k₁)
    @test isequal(tr(commutator(A, B)), 0)
    @test_broken isequal(tr((⊗)(A, B, C)), tr(A)*tr(B)*tr(C))
end

@testset "partial trace tests" begin
    @test isequal(ptrace(A⊗B, 1), tr(A)*B)
    @test isequal(ptrace(A⊗B, 2), tr(B)*A)
end
