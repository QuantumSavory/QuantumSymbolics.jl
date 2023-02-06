using Test
using QuantumSymbolics

#
# single qubit
#

state = Y₁
state_dm = SProjector(state)

p = 0.1

noiseop = PauliNoiseCPTP(p,p,p)
noisy_state = noiseop * state
noisy_state_fromdm = noiseop * state_dm

# for one qubit
# Fρ + (1-F)I/4 = Fρ + (1-F)(ρ + XρX + YρY + ZρZ)/4 = (1-3p)ρ + pXρX + pYρY + pZρZ
# therefore 3/4F+1/4 = 1-3p
# therefore 3/4F = 3/4-3p
F = 1-4p

mixed_dm = MixedState(state_dm)
noisy_state_depol = F*state_dm + (1-F)*mixed_dm # TODO make a depolarization helper

@test tr(express(noisy_state)) ≈ tr(express(noisy_state_fromdm)) ≈ tr(express(noisy_state_depol)) ≈ 1
@test express(noisy_state) ≈ express(noisy_state_fromdm)
@test express(noisy_state) ≈ express(noisy_state_depol)

#
# two qubits
#

pure_pair = (Z₁⊗Z₁ + Z₂⊗Z₂) / √2
pure_pair_dm = SProjector(pure_pair)

p = 0.1

noiseop = PauliNoiseCPTP(p,p,p)
noisy_pair = (noiseop ⊗ noiseop) * pure_pair
noisy_pair_fromdm = (noiseop ⊗ noiseop) * pure_pair_dm

@test tr(express(noisy_pair)) ≈ tr(express(noisy_pair_fromdm)) ≈ 1
@test express(noisy_pair) ≈ express(noisy_pair_fromdm)

# TODO
# test against depolarization
# Depolarization over two qubits is different from depolarizing each separately (see related tutorial)
