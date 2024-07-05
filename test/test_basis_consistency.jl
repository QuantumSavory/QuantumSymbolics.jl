using Test
using QuantumSymbolics
using QuantumOptics
using QuantumInterface: IncompatibleBases

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

@op A SpinBasis(1//2) ⊗ SpinBasis(1//2); @op B; 
@ket k; @bra b; @ket l SpinBasis(1//2) ⊗ SpinBasis(1//2);

@test_throws IncompatibleBases A*B
@test_throws IncompatibleBases commutator(A, B)
@test_throws IncompatibleBases anticommutator(A, B)
@test_throws IncompatibleBases A*k
@test_throws IncompatibleBases b*A
@test_throws IncompatibleBases l*b
@test_throws IncompatibleBases b*l