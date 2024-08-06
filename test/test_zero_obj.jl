@testitem "Zero operator" begin
    A = SOperator(:A, SpinBasis(1//2))
    k = SKet(:k, SpinBasis(1//2))
    b = SBra(:b, SpinBasis(1//2))

    Oop = SZeroOperator()
    Ok = SZeroKet()
    Ob = SZeroBra()

    @testset "zero operator tests" begin
        @test isequal(0*A, Oop) && isequal(A*0, Oop)
        @test isequal(2*Oop, Oop) && isequal(Oop*2, Oop) && isequal(Oop/2, Oop)
        @test isequal(Oop + A, A) && isequal(A + Oop, A) && isequal(Oop + Oop, Oop)
        @test isequal(Oop*A, Oop) && isequal(A*Oop, Oop)
        @test isequal(Oop ⊗ A, Oop) && isequal(A ⊗ Oop, Oop) && isequal(Oop*Oop, Oop)
        @test isequal(commutator(A, Oop), Oop) && isequal(commutator(Oop, A), Oop) && isequal(commutator(Oop, Oop), Oop)
        @test isequal(anticommutator(A, Oop), Oop) && isequal(anticommutator(Oop, A), Oop) && isequal(anticommutator(Oop, Oop), Oop)
        @test isequal(projector(Ok), Oop)
        @test isequal(dagger(Oop), Oop)
    end

    @testset "zero bra and ket tests" begin
        @test isequal(0*k, Ok) && isequal(k*0, Ok)
        @test isequal(2*Ok, Ok) && isequal(Ok*2, Ok) && isequal(Ok/2, Ok)
        @test isequal(Ok + k, k) && isequal(k + Ok, k) && isequal(Ok + Ok, Ok)
        @test isequal(Ok ⊗ k, Ok) && isequal(k ⊗ Ok, Ok)
        @test isequal(0*b, Ob) && isequal(b*0, Ob)
        @test isequal(2*Ob, Ob) && isequal(Ob*2, Ob) && isequal(Ob/2, Ob)
        @test isequal(Ob + b, b) && isequal(b + Ob, b) && isequal(Ob + Ob, Ob)
        @test isequal(Ob ⊗ b, Ob) && isequal(b ⊗ Ob, Ob)
        @test isequal(Oop*k, Ok) && isequal(A*Ok, Ok) && isequal(Oop*Ok, Ok)
        @test isequal(b*Oop, Ob) && isequal(Ob*A, Ob) && isequal(Ob*Oop, Ob)
        @test isequal(Ok*b, Oop) && isequal(k*Ob, Oop) && isequal(Ok*Ob, Oop)
        @test isequal(Ob*k, 0) && isequal(b*Ok, 0) && isequal(Ob*Ok, 0)
    end
end
