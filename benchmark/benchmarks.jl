using QuantumSymbolics
import QuantumOpticsBase
import QuantumClifford

using BenchmarkTools

const SUITE = BenchmarkGroup()
@ket k1; @ket k2; @bra b1; @bra b2; @op A; @op B; @op C;

# Time to import and first usage of simple operations
SUITE["latency"] = BenchmarkGroup(["slow"])
load_command = `julia --quiet --project=./ --eval="using QuantumSymbolics"`
ttfx_command = `
    julia --quiet --project=./ --eval="""
        using QuantumSymbolics;
        @ket k1; @op A;
        A * commutator(A,X) * k1
    """`
SUITE["latency"]["using"] = @benchmarkable run(load_command) samples=3 seconds=15
SUITE["latency"]["ttf_operation"] = @benchmarkable run(ttfx_command) samples=3 seconds=15
SUITE["latency"]["ttf_simplify"] = @benchmarkable qsimplify(X*Y) samples=1 evals=1


# Symbolic object creation
SUITE["creation"] = BenchmarkGroup(["symbolic"])
SUITE["creation"]["ket"] = @benchmarkable @ket _k
SUITE["creation"]["op"] = @benchmarkable @op _A
SUITE["creation"]["super_op"] = @benchmarkable @superop _S

SUITE["creation"]["large_trees"] = BenchmarkGroup(["allocs"])
function large_tree_with_plenty_reallocations(layers)
    expr_op = QuantumSymbolics.I
    expr_ket = X1
    for _ in 1:layers
        expr_op = rand([X, Y, Z, H]) + (rand([X, Y, Z, H]) * expr_op)
        expr_ket = (expr_op * expr_ket) + rand([X1, X2, Y1, Y2, Z1, Z2])
    end
    return expr_op, expr_ket
end
SUITE["creation"]["large_trees"]["10_layers"] = @benchmarkable large_tree_with_plenty_reallocations(10)
SUITE["creation"]["large_trees"]["50_layers"] = @benchmarkable large_tree_with_plenty_reallocations(50)


# Basic operations
SUITE["operations"] = BenchmarkGroup(["symbolic"])
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
SUITE["linalg"] = BenchmarkGroup(["symbolic"])
SUITE["linalg"]["trace"] = @benchmarkable tr($A)
SUITE["linalg"]["ptrace"] = @benchmarkable ptrace($A ⊗ $B, 1)
SUITE["linalg"]["inverse"] = @benchmarkable inv($A)
SUITE["linalg"]["dagger"] = @benchmarkable dagger($A)
SUITE["linalg"]["conjugate"] = @benchmarkable conj($A)
SUITE["linalg"]["transpose"] = @benchmarkable transpose($A)
SUITE["linalg"]["commutator"] = @benchmarkable commutator($A, $B)
SUITE["linalg"]["anticommutator"] = @benchmarkable anticommutator($A, $B)


# Simplification benchmarks
SUITE["manipulation"] = BenchmarkGroup(["symbolic"])
compact_pauli_expr = (H * (X+Y+Z)) * (H * (Y1+Y2+Z1))
expanded_pauli_expr = qexpand(compact_pauli_expr)
commutator_expr = commutator(X, commutator(Y, commutator(X, Z)))

SUITE["manipulation"]["expand"]["distribution"] = @benchmarkable qexpand($compact_pauli_expr)
SUITE["manipulation"]["expand"]["commutator"] = @benchmarkable qexpand($commutator_expr)
SUITE["manipulation"]["simplify"]["applicable_rules"] = @benchmarkable qsimplify($expanded_pauli_expr, rewriter=qsimplify_pauli)
# Expression isn't simplified with fock rules. Testing how fast we go through inapplicable rules.
SUITE["manipulation"]["simplify"]["irrelevant_rules"] = @benchmarkable qsimplify($expanded_pauli_expr, rewriter=qsimplify_fock)
SUITE["manipulation"]["simplify"]["commutator"] = @benchmarkable qsimplify($commutator_expr, rewriter=qsimplify_commutator)


# Expression benchmarks
SUITE["express"] = BenchmarkGroup(["express"])
clear_cache!(x) = empty!(x.metadata.express_cache)
simple_op = X⊗Y
simple_ket = Z1⊗Z1
pauli_op_4 = YCX * transpose(Z⊗Y) * YCZ * dagger(Y⊗X) * conj(ZCY) * exp(X ⊗ (2-3im)X) 
pauli_state_8 = (conj(XCY⊗Y) + dagger(Z⊗YCX) + transpose(0.5im*Y ⊗ exp(XCY))) * (X1⊗Y1⊗Z1)

SUITE["express"]["optics"]["simple_op"] = @benchmarkable express($simple_op) setup=clear_cache!(simple_op) evals=1
SUITE["express"]["optics"]["simple_ket"] = @benchmarkable express($simple_ket) setup=clear_cache!(simple_ket) evals=1
SUITE["express"]["optics"]["pauli_op_4"] = @benchmarkable express($pauli_op_4) setup=clear_cache!(pauli_op_4) evals=1
SUITE["express"]["optics"]["pauli_state_8"] = @benchmarkable express($pauli_state_8) setup=clear_cache!(pauli_state_8) evals=1

# TODO: add additional clifford expressions
SUITE["express"]["clifford"]["simple_ket"] = @benchmarkable express($simple_ket, CliffordRepr()) setup=clear_cache!(simple_ket) evals=1
SUITE["express"]["clifford"]["simple_observable"] = @benchmarkable express($simple_op, CliffordRepr(), UseAsObservable()) setup=clear_cache!(simple_op) evals=1

