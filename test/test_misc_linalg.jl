@testitem "Misc linear algebra" begin
    @op A; @op B;
    O = SZeroOperator()

    @testset "Complex Conjugate" begin
        @test isequal(conj(O), O)
        @test isequal(conj(conj(A)), A)
    end

    @testset "Transpose" begin
        @test isequal(transpose(2*A), 2*transpose(A))
        @test isequal(transpose(A+B), transpose(A)+transpose(B))
        @test isequal(transpose(A*B), transpose(B)*transpose(A))
        @test isequal(transpose(A⊗B), transpose(A)⊗transpose(B))
        @test isequal(transpose(O), O)
        @test isequal(transpose(transpose(A)), A)
    end

    @testset "Vectorization" begin
        @test isequal(vec(2*A), 2*vec(A))
        @test isequal(vec(A+B), vec(A)+vec(B))
        @test isequal(basis(vec(A)), SpinBasis(1//2)⊗SpinBasis(1//2))
    end

    @testset "Exponential" begin
        @test isequal(exp(A), SExpOperator(A))
    end
end
