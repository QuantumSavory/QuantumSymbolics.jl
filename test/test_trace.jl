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

@testset "partial trace tests" begin
    @test isequal(ptrace((⊗)(A, B, C), 1), tr(A)*(B⊗C))
    @test isequal(ptrace((⊗)(A, B, C), 2), tr(B)*(A⊗C))
    @test isequal(ptrace((⊗)(A, B, C), 3), tr(C)*(A⊗B))
    @test isequal(ptrace((k₁*b₁)⊗A + (k₂*b₂)⊗B, 1), (b₁*k₁)*A + (b₂*k₂)*B)
    @test isequal(ptrace((k₁*b₁)⊗A + (k₂*b₂)⊗B, 2), tr(A)*(k₁*b₁) + tr(B)*(k₂*b₂))
end
