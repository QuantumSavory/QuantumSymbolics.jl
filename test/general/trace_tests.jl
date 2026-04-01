using Test
using QuantumSymbolics

@testset "Trace" begin

    @bra b₁; @bra b₂;
    @ket k₁; @ket k₂;
    @op A; @op B; @op C; @op D; @op E; @op F;
    @op 𝒪 SpinBasis(1//2)⊗SpinBasis(1//2); @op 𝒫 SpinBasis(1//2)⊗SpinBasis(1//2);
    @op ℒ SpinBasis(1//2)⊗SpinBasis(1//2);

    @testset "trace tests" begin
        @test isequal(tr(2*A), 2*tr(A))
        @test isequal(tr(A+B), tr(A)+tr(B))
        @test isequal(tr(k₁*b₁), b₁*k₁)
        @test isequal(tr(commutator(A, B)), 0)
        @test isequal(tr(A⊗B⊗C), tr(A)*tr(B)*tr(C))
    end

    exp1 = (k₁*b₁)⊗A + (k₂*b₂)⊗B
    exp2 = A⊗(B⊗C + D⊗E)
    @testset "partial trace tests" begin

        # tests for ptrace(x::Symbolic{AbstractOperator}, s)
        @test isequal(ptrace(𝒪, 1), SPartialTrace(𝒪, 1))
        @test isequal(ptrace(𝒪, 2), SPartialTrace(𝒪, 2))
        @test isequal(ptrace(A, 1), tr(A))
        @test isequal(ptrace(A*(B+C), 1), tr(A*B)+tr(A*C))
        @test isequal(QuantumSymbolics.basis(ptrace(𝒪, 1)), SpinBasis(1//2))
        @test isequal(QuantumSymbolics.basis(ptrace(𝒪, 2)), SpinBasis(1//2))

        # tests for ptrace(x::SAddOperator, s)
        @test isequal(ptrace(A+B, 1), tr(A+B))
        @test isequal(ptrace(2*(A⊗B)+(C⊗D), 1), 2*tr(A)*B + tr(C)*D)
        @test isequal(ptrace((A⊗B)+(C⊗D), 1), tr(A)*B + tr(C)*D)
        @test isequal(ptrace((A⊗B⊗C)+(D⊗E⊗F), 1), tr(A)*(B⊗C) + tr(D)*(E⊗F))
        @test isequal(ptrace(𝒪 + 𝒫, 1), SPartialTrace(𝒪 + 𝒫, 1))
        @test isequal(ptrace(𝒪*ℒ + 𝒫*ℒ, 1), SPartialTrace(𝒪*ℒ + 𝒫*ℒ, 1))
        @test isequal(ptrace(𝒪⊗ℒ + 𝒫⊗ℒ, 1), SPartialTrace(𝒪⊗ℒ + 𝒫⊗ℒ, 1))

        # tests for ptrace(x::STensorOperator, s)
        @test isequal(ptrace(A⊗(B⊗C + D⊗E), 1),  tr(A)*(B⊗C) + tr(A)*(D⊗E)) 
        @test isequal(ptrace(𝒪⊗A, 1), SPartialTrace(𝒪⊗A, 1))
        @test isequal(ptrace(A⊗B, 1), tr(A)*B)
        @test isequal(ptrace(A⊗B⊗C, 1), tr(A)*(B⊗C))

        # additional tests 
        @test isequal(ptrace(exp1, 1), (b₁*k₁)*A + (b₂*k₂)*B)
        @test isequal(basis(ptrace(exp1, 1)), SpinBasis(1//2))
        @test isequal(ptrace(exp1, 2), tr(A)*(k₁*b₁) + tr(B)*(k₂*b₂))
        @test isequal(basis(ptrace(exp1, 2)), SpinBasis(1//2))

        @test isequal(ptrace(exp2, 1), tr(A)*(B⊗C) + tr(A)*(D⊗E))
        @test isequal(basis(ptrace(exp2, 1)), SpinBasis(1//2)⊗SpinBasis(1//2))
        @test isequal(ptrace(exp2, 2), tr(B)*(A⊗C) + tr(D)*(A⊗E))
        @test isequal(basis(ptrace(exp2, 2)), SpinBasis(1//2)⊗SpinBasis(1//2))
        @test isequal(ptrace(exp2, 3), tr(C)*(A⊗B) + tr(E)*(A⊗D))
        @test isequal(basis(ptrace(exp2, 3)), SpinBasis(1//2)⊗SpinBasis(1//2))
    end
end
