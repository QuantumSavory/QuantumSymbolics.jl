@testitem "Test throwing" begin
    using QuantumOptics
    using QuantumInterface: IncompatibleBases

    @op A SpinBasis(1//2) ⊗ SpinBasis(1//2); @op B; @op C;
    @ket k; @bra b; @ket l SpinBasis(1//2) ⊗ SpinBasis(1//2);
    fb = FockBasis(10)

    @test_throws IncompatibleBases A*B
    @test_throws IncompatibleBases commutator(A, B)
    @test_throws IncompatibleBases anticommutator(A, B)
    @test_throws IncompatibleBases A*k
    @test_throws IncompatibleBases b*A
    @test_throws IncompatibleBases l*b
    @test_throws IncompatibleBases b*l
    @test_throws ArgumentError ptrace(B, 2)
    @test_throws ArgumentError ptrace(B+C, 2)
    @test_throws ArgumentError TwoSqueezedState(pi, fb^3)
    @test_throws ArgumentError TwoSqueezeOp(pi, fb^3)
    @test_throws ArgumentError BeamSplitterOp(pi, fb^3)
end