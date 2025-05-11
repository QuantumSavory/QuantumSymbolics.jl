@testitem "Base show methods" begin
    @op A; @op B;
    @superop S;
    @bra b₁; @bra b₂;
    @ket k₁; @ket k₂;

    @testset "symbolic literal objects" begin
        @test repr(k₁) == "|k₁⟩"
        @test repr(b₁) == "⟨b₁|"
        @test repr(A) == "A"
        @test repr(S) == "S"
        @test repr(zero(k₁)) == repr(zero(b₁)) == repr(zero(A)) == repr(zero(S)) == "𝟎"
    end

    @testset "symbolic addition" begin
        @test repr(k₁ + k₂) == "|k₁⟩+|k₂⟩"
        @test repr(b₁ + b₂) == "⟨b₁|+⟨b₂|"
        @test repr(A + B) == "A+B"
    end
    
    @testset "symbolic application products" begin
        @test repr(A * k₁) == "A|k₁⟩"
        @test repr(b₁ * A) == "⟨b₁|A"
        @test repr((A + B) * k₁) == "(A+B)|k₁⟩"
        @test repr(b₁ * (A + B)) == "⟨b₁|(A+B)"
        @test repr((A + B) * (k₁ + k₂)) == "(A+B)(|k₁⟩+|k₂⟩)"
        @test repr((b₁ + b₂) * (A + B)) == "(⟨b₁|+⟨b₂|)(A+B)"
        @test repr((A ⊗ B) * SKet(:k, SpinBasis(1//2)^2)) == "(A⊗B)|k⟩"
        @test repr(SBra(:b, SpinBasis(1//2)^2) * (A ⊗ B)) == "⟨b|(A⊗B)"
        @test repr((A ⊗ B) * (k₁ ⊗ k₂)) == "(A⊗B)|k₁⟩|k₂⟩"
        @test repr((b₁ ⊗ b₂) * (A ⊗ B)) == "⟨b₁|⟨b₂|(A⊗B)"
    end

    @testset "symbolic scaling" begin
        @test repr(2 * k₁) == "2|k₁⟩"
        @test repr(2 * b₁) == "2⟨b₁|"
        @test repr(2 * A) == "2A"
        @test repr(2 * (k₁ + k₂)) == "2(|k₁⟩+|k₂⟩)"
        @test repr(2 * (b₁ + b₂)) == "2(⟨b₁|+⟨b₂|)"
        @test repr(2 * (A + B)) == "2(A+B)"
        @test repr(2 * (k₁ ⊗ k₂)) == "2|k₁⟩|k₂⟩"
        @test repr(2 * (b₁ ⊗ b₂)) == "2⟨b₁|⟨b₂|"
        @test repr(2 * (A ⊗ B)) == "2A⊗B"
        @test repr((1 + im) * k₁) == "(1 + 1im)|k₁⟩"
        @test repr((1 + im) * b₁) == "(1 + 1im)⟨b₁|"
        @test repr((1 + im) * A) == "(1 + 1im)A"
        @test repr((1 + im) * (k₁ + k₂)) == "(1 + 1im)(|k₁⟩+|k₂⟩)"
        @test repr((1 + im) * (b₁ + b₂)) == "(1 + 1im)(⟨b₁|+⟨b₂|)"
        @test repr((1 + im) * (A + B)) == "(1 + 1im)(A+B)"
        @test repr((1 + im) * (k₁ ⊗ k₂)) == "(1 + 1im)|k₁⟩|k₂⟩"
        @test repr((1 + im) * (b₁ ⊗ b₂)) == "(1 + 1im)⟨b₁|⟨b₂|"
        @test repr((1 + im) * (A ⊗ B)) == "(1 + 1im)A⊗B"
    end
    
    @testset "symbolic inner and outer products" begin
        @test repr(b₁ * k₁) == "⟨b₁||k₁⟩"
        @test repr(k₁ * b₁) == "|k₁⟩⟨b₁|"
    end

    @testset "symbolic superoperators" begin
        @test repr(S * A) == "S[A]"
    end

    @testset "symbolic commutator and anticommutator" begin
        @test repr(commutator(A, B)) == "[A,B]"
        @test repr(anticommutator(A, B)) == "{A,B}"
    end

    @testset "symbolic linear algebra operations" begin
        @test repr(conj(k₁)) == "|k₁⟩ˣ"
        @test repr(conj(b₁)) == "⟨b₁|ˣ"
        @test repr(conj(A)) == "Aˣ"
        @test repr(projector(k₁)) == "𝐏[|k₁⟩]"
        @test repr(transpose(k₁)) == "|k₁⟩ᵀ"
        @test repr(transpose(b₁)) == "⟨b₁|ᵀ"
        @test repr(transpose(A)) == "Aᵀ"
        @test repr(dagger(k₁)) == "|k₁⟩†"
        @test repr(dagger(b₁)) == "⟨b₁|†"
        @test repr(dagger(A)) == "A†"
        @test repr(tr(A)) == "tr(A)"
        @test repr(ptrace(A ⊗ B, 1)) == "(tr(A))B"
        @test repr(ptrace(SOperator(:A, SpinBasis(1//2)^2), 1)) == "tr1(A)"
        @test repr(inv(A)) == "A⁻¹"
        @test repr(exp(A)) == "exp(A)"
        @test repr(vec(A)) == "|A⟩⟩"
    end
end