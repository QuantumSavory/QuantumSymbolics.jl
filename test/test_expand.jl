using QuantumSymbolics
using Test

@bra b₁; @bra b₂; @bra b₃;
@ket k₁; @ket k₂; @ket k₃;

@op A; @op B; @op C; @op D;

@testset "expand rules" begin
    @test isequal(qexpand(commutator(A, B)), A*B - B*A)
    @test isequal(qexpand(anticommutator(A, B)), A*B + B*A)

    @test isequal(qexpand(A⊗(B+C+D)), A⊗B + A⊗C + A⊗D)
    @test isequal(qexpand(C ⊗ commutator(A, B)), C⊗(A*B) - C⊗(B*A))
    @test isequal(qexpand(k₁⊗(k₂+k₃)), k₁⊗k₂ + k₁⊗k₃)
    @test isequal(qexpand(b₁⊗(b₂+b₃)), b₁⊗b₂ + b₁⊗b₃)

    @test isequal(qexpand((B+C+D)⊗A), B⊗A + C⊗A + D⊗A)
    @test isequal(qexpand(commutator(A, B) ⊗ C), (A*B)⊗C - (B*A)⊗C)
    @test isequal(qexpand((k₂+k₃)⊗k₁), k₂⊗k₁ + k₃⊗k₁)
    @test isequal(qexpand((b₂+b₃)⊗b₁), b₂⊗b₁ + b₃⊗b₁)

    @test isequal(qexpand(A*(B+C+D)), A*B + A*C + A*D)
    @test isequal(qexpand(C * commutator(A, B)), C*A*B - C*B*A)

    @test isequal(qexpand((B+C+D)*A), B*A + C*A + D*A)
    @test isequal(qexpand(commutator(A, B) * C), A*B*C - B*A*C)

    @test isequal(qexpand(A*(B⊗C⊗D)), (A*B)⊗(A*C)⊗(A*D))
    @test isequal(qexpand((B⊗C⊗D)*A), (B*A)⊗(C*A)⊗(D*A))

    @test isequal(qexpand((A⊗B)*(C⊗D)), (A*C)⊗(B*D))
    @test isequal(qexpand((b₁⊗b₂)*(k₁⊗k₂)), (b₁*k₁)*(b₂*k₂))
end