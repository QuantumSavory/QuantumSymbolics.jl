using Test
using QuantumSymbolics

@testset "QuantumOpticsRepr lazy=true" begin
    using QuantumOptics
    r_lazy = QuantumOpticsRepr(lazy=true)
    r_eager = QuantumOpticsRepr()

    # Basic construction
    @testset "Construction" begin
        @test QuantumOpticsRepr() isa QuantumOpticsRepr
        @test QuantumOpticsRepr(cutoff=4) isa QuantumOpticsRepr
        @test QuantumOpticsRepr(lazy=true) isa QuantumOpticsRepr
        @test QuantumOpticsRepr(cutoff=4, lazy=true) isa QuantumOpticsRepr
        @test r_lazy.lazy == true
        @test r_eager.lazy == false
        @test r_eager.cutoff == 2
    end

    # Test Sum → LazySum
    @testset "SAddOperator → LazySum" begin
        op = tensor(X, I) + tensor(I, Z)
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)

        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), eager_op)
    end

    # Test Mul → LazyProduct
    @testset "SMulOperator → LazyProduct" begin
        op1 = tensor(X, I)
        op2 = tensor(I, Z)
        prod_op = op1 * op2

        lazy_prod = express(prod_op, r_lazy)
        eager_prod = express(prod_op, r_eager)

        @test lazy_prod isa LazyProduct
        @test isapprox(dense(lazy_prod), eager_prod)
    end

    # Test TensorProduct → LazyTensor
    @testset "STensorOperator → LazyTensor" begin
        op = tensor(X, Y)

        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)

        @test lazy_op isa LazyTensor
        @test isapprox(dense(lazy_op), eager_op)
    end

    # Test multi-term sum
    @testset "Multi-term SAddOperator" begin
        op = tensor(X, I) + tensor(I, Z) + tensor(Z, X)
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)

        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), eager_op)
    end

    # Test Cutoff preservation
    @testset "Cutoff with lazy=true" begin
        r_lazy_cutoff = QuantumOpticsRepr(cutoff=4, lazy=true)

        # Fock operators should still respect cutoff
        @test express(DestroyOp(), r_eager) isa AbstractOperator
        @test express(DestroyOp(), r_lazy_cutoff) isa AbstractOperator
    end

    # Test Scaled operators
    @testset "Scaled operators" begin
        op = 2 * (tensor(X, I) + tensor(I, Y))
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)

        @test isapprox(dense(lazy_op), eager_op)
    end

    # Test commutator
    @testset "Commutator" begin
        c = commutator(X, Y)
        lazy_c = express(c, r_lazy)
        eager_c = express(c, r_eager)

        @test isapprox(dense(lazy_c), eager_c)
    end

    # Test anticommutator
    @testset "Anticommutator" begin
        a = anticommutator(X, Y)
        lazy_a = express(a, r_lazy)
        eager_a = express(a, r_eager)

        @test isapprox(dense(lazy_a), eager_a)
    end

    # Test Hamiltonian-like structure (common use case)
    @testset "Hamiltonian structure" begin
        # H = -J1*σz1*σz2 - J2*σx1*σx2
        # This is a typical spin-chain Hamiltonian
        H = -0.5 * tensor(Z, I) - 0.5 * tensor(I, Z) - 0.1 * tensor(X, X)
        lazy_H = express(H, r_lazy)
        eager_H = express(H, r_eager)

        @test isapprox(dense(lazy_H), eager_H)
    end

    # Test nested expressions
    @testset "Nested expressions" begin
        inner = tensor(X, I) + tensor(I, X)
        outer = inner * inner
        lazy_outer = express(outer, r_lazy)
        eager_outer = express(outer, r_eager)

        @test isapprox(dense(lazy_outer), eager_outer)
    end
end
