using Test
using QuantumSymbolics

# Test that the inhomogeneous binary structs have concretely typed fields

@ket k
@op A
@bra b

# SApplyKet
apply_ket = A * k
@test isa(apply_ket, SApplyKet)
@test fieldtype(typeof(apply_ket), :op) <: Symbolic{AbstractOperator}
@test fieldtype(typeof(apply_ket), :ket) <: Symbolic{AbstractKet}

# SApplyBra
apply_bra = b * A
@test isa(apply_bra, SApplyBra)
@test fieldtype(typeof(apply_bra), :bra) <: Symbolic{AbstractBra}
@test fieldtype(typeof(apply_bra), :op)  <: Symbolic{AbstractOperator}

# SBraKet (inner product)
inner = b * k
@test isa(inner, SBraKet)
@test fieldtype(typeof(inner), :bra) <: Symbolic{AbstractBra}
@test fieldtype(typeof(inner), :ket) <: Symbolic{AbstractKet}

# SOuterKetBra (outer product)
outer = k * b
@test isa(outer, SOuterKetBra)
@test fieldtype(typeof(outer), :ket) <: Symbolic{AbstractKet}
@test fieldtype(typeof(outer), :bra) <: Symbolic{AbstractBra}
