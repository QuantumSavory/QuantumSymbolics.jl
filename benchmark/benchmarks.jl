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
