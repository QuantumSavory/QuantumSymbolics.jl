using QuantumSymbolics
using Test

a = SBra(:a, SpinBasis(1//2))
b = SKet(:b, SpinBasis(1//2))

A = SOperator(:A, SpinBasis(1//2))
B = SOperator(:B, SpinBasis(1//2))
C = SOperator(:C, SpinBasis(1//2))

@test dagger(a*b) == dagger(b)*dagger(a)
@test dagger(2*A*B*b) == 2*dagger(b)*dagger(B)*dagger(A)
@test dagger(dagger(A)) == A