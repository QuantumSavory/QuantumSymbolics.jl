using QuantumSymbolics
using Test

@testset "simplify errors" begin
    @test_throws ErrorException qsimplify(X)
end

@testset "MulOperator tests" begin
    @test isequal(qsimplify(X*X,rewriter=qsimplify_pauli), I)
    @test isequal(qsimplify(Y*Y,rewriter=qsimplify_pauli), I)
    @test isequal(qsimplify(Z*Z,rewriter=qsimplify_pauli), I)
    @test isequal(qsimplify(X*Y,rewriter=qsimplify_pauli), im*Z)
    @test isequal(qsimplify(Y*Z,rewriter=qsimplify_pauli), im*X)
    @test isequal(qsimplify(Z*X,rewriter=qsimplify_pauli), im*Y)
    @test isequal(qsimplify(Y*X,rewriter=qsimplify_pauli), -im*Z)
    @test isequal(qsimplify(Z*Y,rewriter=qsimplify_pauli), -im*X)
    @test isequal(qsimplify(X*Z,rewriter=qsimplify_pauli), -im*Y)
    @test isequal(qsimplify(H*X*H,rewriter=qsimplify_pauli), Z)
    @test isequal(qsimplify(H*Y*H,rewriter=qsimplify_pauli), -Y)
    @test isequal(qsimplify(H*Z*H,rewriter=qsimplify_pauli), X)
end

@testset "ApplyKet tests" begin
   @test isequal(qsimplify(X*X1,rewriter=qsimplify_pauli), X1)
   @test isequal(qsimplify(Y*X1,rewriter=qsimplify_pauli), -im*X2)
   @test isequal(qsimplify(Z*X1,rewriter=qsimplify_pauli), X2)

   @test isequal(qsimplify(X*X2,rewriter=qsimplify_pauli), -X2)
   @test isequal(qsimplify(Y*X2,rewriter=qsimplify_pauli), im*X1)
   @test isequal(qsimplify(Z*X2,rewriter=qsimplify_pauli), X1)
    
   @test isequal(qsimplify(X*Y1,rewriter=qsimplify_pauli), im*Y2)
   @test isequal(qsimplify(Y*Y1,rewriter=qsimplify_pauli), Y1)
   @test isequal(qsimplify(Z*Y1,rewriter=qsimplify_pauli), Y2)

   @test isequal(qsimplify(X*Z1,rewriter=qsimplify_pauli), Z2)
   @test isequal(qsimplify(Y*Z1,rewriter=qsimplify_pauli), im*Z2)
   @test isequal(qsimplify(Z*Z1,rewriter=qsimplify_pauli), Z1)

   @test isequal(qsimplify(X*Z2,rewriter=qsimplify_pauli), Z1)
   @test isequal(qsimplify(Y*Z2,rewriter=qsimplify_pauli), -im*Z1)
   @test isequal(qsimplify(Z*Z2,rewriter=qsimplify_pauli), -Z2)

   @test isequal(qsimplify(H*X1,rewriter=qsimplify_pauli), Z1)
   @test isequal(qsimplify(H*X2,rewriter=qsimplify_pauli), Z2)
   @test isequal(qsimplify(H*Y1,rewriter=qsimplify_pauli), (X1+im*X2)/sqrt(2))
   @test isequal(qsimplify(H*Y2,rewriter=qsimplify_pauli), (X1-im*X2)/sqrt(2))
   @test isequal(qsimplify(H*Z1,rewriter=qsimplify_pauli), X1)
   @test isequal(qsimplify(H*Z2,rewriter=qsimplify_pauli), X2)
end