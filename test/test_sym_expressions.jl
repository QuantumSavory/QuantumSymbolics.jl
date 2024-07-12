using Test
using QuantumSymbolics

@test +(Z1) == Z1
@test +(Z) == Z
@test isequal(Z1 - Z2, Z1 + (-Z2))
@test_broken isequal(Z1 - 2*Z2 + 2*X1, -2*Z2 + Z1 + 2*X1)
@test_broken isequal(Z1 - 2*Z2 + 2*X1, Z1 + 2*(-Z2+X1))

state1 = XBasisState(1, SpinBasis(1//2))
state2 = XBasisState(1, SpinBasis(1//2))
state3 = XBasisState(2, SpinBasis(1//2))

@test isequal(state1, state2)
@test !isequal(state1, state3)
