@testitem "Misc linear algebra" begin
    @op A; @op B;
    O = SZeroOperator()

    @bra p
    @bra q
        
    @ket m
    @ket n
    
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

    @testset "Vector of Operators" begin
        @test isequal([1 1;-im im]*[A;B], [A + B;im*B-im*A])  
    end

    @testset "Vector of Kets" begin
        @test isequal([1 1;-im im] *[p;q], [p + q;im*q-im*p])
    end

    @testset "Vector of Bras" begin
        @test isequal([1 1;-im im] *[m;n], [m + n;im*n-im*m])
    end

end
