using QuantumSymbolics
using Test

@bra b₁; @bra b₂;
@ket k₁; @ket k₂;
@op A; @op B; @op C; @op D; @op E; @op F; @op 𝒪 SpinBasis(1//2)⊗SpinBasis(1//2);

@testset "trace tests" begin
    @test isequal(tr(2*A), 2*tr(A))
    @test isequal(tr(A+B), tr(A)+tr(B))
    @test isequal(tr(k₁*b₁), b₁*k₁)
    @test isequal(tr(commutator(A, B)), 0)
    @test isequal(tr(A⊗B⊗C), tr(A)*tr(B)*tr(C))
end

exp1 = A⊗B⊗C
exp2 = (k₁*b₁)⊗A + (k₂*b₂)⊗B
exp3 = A⊗(B⊗C + D⊗E)
exp4 = A⊗(B⊗C + D⊗E)*F
@testset "partial trace tests" begin
    @test isequal(ptrace(𝒪, 1), SPartialTrace(𝒪, 1))
    @test isequal(QuantumSymbolics.basis(ptrace(𝒪, 1)), SpinBasis(1//2))
    @test isequal(ptrace(𝒪, 2), SPartialTrace(𝒪, 2))
    @test isequal(QuantumSymbolics.basis(ptrace(𝒪, 2)), SpinBasis(1//2))

    @test isequal(ptrace(exp1, 1), tr(A)*(B⊗C))
    @test isequal(QuantumSymbolics.basis(ptrace(exp1, 1)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp1, 2), tr(B)*(A⊗C))
    @test isequal(QuantumSymbolics.basis(ptrace(exp1, 2)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp1, 3), tr(C)*(A⊗B))
    @test isequal(QuantumSymbolics.basis(ptrace(exp1, 3)), SpinBasis(1//2)⊗SpinBasis(1//2))

    @test isequal(ptrace(exp2, 1), (b₁*k₁)*A + (b₂*k₂)*B)
    @test isequal(QuantumSymbolics.basis(ptrace(exp2, 1)), SpinBasis(1//2))
    @test isequal(ptrace(exp2, 2), tr(A)*(k₁*b₁) + tr(B)*(k₂*b₂))
    @test isequal(QuantumSymbolics.basis(ptrace(exp2, 2)), SpinBasis(1//2))

    @test isequal(ptrace(exp3, 1), tr(A)*(B⊗C) + tr(A)*(D⊗E))
    @test isequal(QuantumSymbolics.basis(ptrace(exp3, 1)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp3, 2), tr(B)*(A⊗C) + tr(D)*(A⊗E))
    @test isequal(QuantumSymbolics.basis(ptrace(exp3, 2)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp3, 3), tr(C)*(A⊗B) + tr(E)*(A⊗D))
    @test isequal(QuantumSymbolics.basis(ptrace(exp3, 3)), SpinBasis(1//2)⊗SpinBasis(1//2))

    @test isequal(ptrace(exp4, 1), tr(A*F)*((B*F)⊗(C*F)) + tr(A*F)*((D*F)⊗(E*F)))
    @test isequal(QuantumSymbolics.basis(ptrace(exp4, 1)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp4, 2), tr(B*F)*((A*F)⊗(C*F)) + tr(D*F)*((A*F)⊗(E*F)))
    @test isequal(QuantumSymbolics.basis(ptrace(exp4, 2)), SpinBasis(1//2)⊗SpinBasis(1//2))
    @test isequal(ptrace(exp4, 3), tr(C*F)*((A*F)⊗(B*F)) + tr(E*F)*((A*F)⊗(D*F)))
    @test isequal(QuantumSymbolics.basis(ptrace(exp4, 2)), SpinBasis(1//2)⊗SpinBasis(1//2))
end
