using QuantumSymbolics
using QuantumOptics
using QuantumClifford
using BenchmarkTools

const SUITE = BenchmarkGroup()

SUITE["import_time"] = BenchmarkGroup(["slow"])
load_command = `julia --quiet --project=./ --eval="using QuantumSymbolics"`
ttfx_command = `
    julia --quiet --project=./ --eval="""
        using QuantumSymbolics;
        @ket k1; @op A;
        A * commutator(A,X) * k1 |> qexpand
    """`
SUITE["import_time"]["using"] = @benchmarkable run(load_command) samples=3 seconds=15
SUITE["import_time"]["ttfx"] = @benchmarkable run(ttfx_command) samples=3 seconds=15
#TODO: qsimplify ttfx is very slow

# Basic symbolic object creation
SUITE["creation"] = BenchmarkGroup(["symbolic"])
SUITE["creation"]["ket"] = @benchmarkable @ket k
SUITE["creation"]["op"] = @benchmarkable @op A
SUITE["creation"]["super_op"] = @benchmarkable @superop S

# Basic operations benchmarks
SUITE["operations"] = BenchmarkGroup(["symbolic"])
@ket k1; @ket k2; @bra b1; @bra b2; @op A; @op B; @op C;

SUITE["operations"]["scaling"] = BenchmarkGroup()
SUITE["operations"]["scaling"]["ket"] = @benchmarkable 2 * $k1
SUITE["operations"]["scaling"]["op"] = @benchmarkable 3 * $A

SUITE["operations"]["addition"] = BenchmarkGroup()
SUITE["operations"]["addition"]["ket"] = @benchmarkable $k1 + $k2
SUITE["operations"]["addition"]["op"] = @benchmarkable $A + $B

SUITE["operations"]["multiplication"] = BenchmarkGroup()
SUITE["operations"]["multiplication"]["bra_ket"] = @benchmarkable $b1 * $k1
SUITE["operations"]["multiplication"]["op_ket"] = @benchmarkable $A * $k1
SUITE["operations"]["multiplication"]["bra_op"] = @benchmarkable $b1 * $A
SUITE["operations"]["multiplication"]["inner"] = @benchmarkable $b1 * $k1
SUITE["operations"]["multiplication"]["outer"] = @benchmarkable $k1 * $b1
SUITE["operations"]["multiplication"]["op"] = @benchmarkable $A * $B 
SUITE["operations"]["multiplication"]["many"] = @benchmarkable $k1 * $b2 * $k2 * $b1 * $A * $B

SUITE["operations"]["tensor"] = BenchmarkGroup()
SUITE["operations"]["tensor"]["ket"] = @benchmarkable $k1 ⊗ $k2
SUITE["operations"]["tensor"]["op"] = @benchmarkable $A ⊗ $B
SUITE["operations"]["tensor"]["many"] = @benchmarkable $A ⊗ $B ⊗ $C ⊗ $A ⊗ $B ⊗ $C

# Linear algebra operations
SUITE["linalg"]["creation"] = BenchmarkGroup(["symbolic"])
SUITE["linalg"]["trace"] = @benchmarkable tr($A)
SUITE["linalg"]["ptrace"] = @benchmarkable ptrace($A ⊗ $B, 1)
SUITE["linalg"]["inverse"] = @benchmarkable inv($A)
SUITE["linalg"]["dagger"] = @benchmarkable dagger($A)
SUITE["linalg"]["conjugate"] = @benchmarkable conj($A)
SUITE["linalg"]["transpose"] = @benchmarkable transpose($A)
SUITE["linalg"]["commutator"] = @benchmarkable commutator($A, $B)
SUITE["linalg"]["anticommutator"] = @benchmarkable anticommutator($A, $B)

# Simplification benchmarks
SUITE["manipulation"] = BenchmarkGroup()
compact_pauli_expr = (H * (X+Y+Z)) * (H * (Y1+Y2+Z1))
expanded_pauli_expr = qexpand(compact_pauli_expr)

SUITE["manipulation"]["expand"] = @benchmarkable qexpand($compact_pauli_expr)
SUITE["manipulation"]["simplify"]["applicable_rules"] = @benchmarkable qsimplify($expanded_pauli_expr, rewriter=qsimplify_pauli)
SUITE["manipulation"]["simplify"]["irrelevant_rules"] = @benchmarkable qsimplify($expanded_pauli_expr, rewriter=qsimplify_fock)

# Expression benchmarks
SUITE["express"] = BenchmarkGroup(["express"])
clear_cache!(x) = empty!(x.metadata.express_cache)
state_4 = (Z1⊗Z1 + Z2⊗Z2)/√2
pauli_op_4 = YCX * transpose(Z⊗Y) * YCZ * dagger(Y⊗X) * conj(ZCY) * exp(X ⊗ (2-3im)X) 
pauli_state_8 = (conj(XCY⊗Y) + dagger(Z⊗YCX) + transpose(0.5im*Y ⊗ exp(XCY))) * (X1⊗Y1⊗Z1)

SUITE["express"]["optics"]["state_4"] = @benchmarkable express($state_4) setup=clear_cache!(state_4)
SUITE["express"]["optics"]["pauli_op_4"] = @benchmarkable express($pauli_op_4) setup=clear_cache!(pauli_op_4)
SUITE["express"]["optics"]["pauli_state_8"] = @benchmarkable express($pauli_state_8) setup=clear_cache!(pauli_state_8)

# TODO: not sure what else to add here
test_op = X⊗Y
SUITE["express"]["clifford"]["operator"] = @benchmarkable express($X, CliffordRepr()) setup=clear_cache!(X)
SUITE["express"]["clifford"]["observable"] = @benchmarkable express($test_op, CliffordRepr(), UseAsObservable()) setup=clear_cache!(test_op)

