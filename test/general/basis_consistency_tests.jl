@testitem "Basis consistency" begin
    using QuantumOptics

    @test express(Z*Z1) == express(Z1)
    @test express(Z*Z2) == -express(Z2)
    @test express(X*X1) == express(X1)
    @test express(X*X2) == -express(X2)
    @test express(Y*Y1) == express(Y1)
    @test express(Y*Y2) == -express(Y2)
    @test express(Pm*Z1) == express(Z2)
    @test express(Pp*Z2) == express(Z1)
    @test express(Pm*L0) == express(L1)
    @test express(Pp*L1) == express(L0)

    @op A; @op B; @op C; @op O; @ket k;
    @superop S; K = kraus(A, B, C);

    @test basis(K) == basis(A)
end
