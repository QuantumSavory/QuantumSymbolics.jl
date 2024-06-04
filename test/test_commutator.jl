using QuantumSymbolics
using QuantumInterface: SpinBasis
using Test

A = SOperator(:A, SpinBasis(1//2))
B = SOperator(:B, SpinBasis(1//2))

@test expand(commutator(A, B)) === (A*B-1B*A)
@test commutator(2*A, B) === commutator(A, 2*B) === 2*commutator(A, B)
@test commutator(A, A) == 0
@test anticommutator(A, B) === SAnticommutator(A, B)
@test expand(anticommutator(A, B)) === (A*B + B*A)
@test anticommutator(2*A, B) === anticommutator(A, 2*B) === 2*anticommutator(A, B)
@test anticommutator(A, -A) == 0
