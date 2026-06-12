using Test
using QuantumSymbolics
using QuantumOptics

@testset "Lazy express" begin
    r_lazy = QuantumOpticsRepr(lazy=true)
    r_eager = QuantumOpticsRepr()

    # QuantumOpticsRepr constructor backward compatibility
    @test QuantumOpticsRepr().lazy == false
    @test QuantumOpticsRepr().cutoff == 2
    @test QuantumOpticsRepr(cutoff=4).lazy == false
    @test QuantumOpticsRepr(cutoff=4, lazy=true).lazy == true
    @test QuantumOpticsRepr(cutoff=4, lazy=true).cutoff == 4

    # LazySum from symbolic operator addition
    @testset "LazySum" begin
        op = X + Z
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)
        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), eager_op)

        # Sum with coefficients
        op2 = 2*X + 3im*Z
        lazy_op2 = express(op2, r_lazy)
        eager_op2 = express(op2, r_eager)
        @test lazy_op2 isa LazySum
        @test isapprox(dense(lazy_op2), eager_op2)

        # Sum of tensor products (Hamiltonian-like)
        ham = tensor(X, IdentityOp(X)) + tensor(IdentityOp(X), Z)
        lazy_ham = express(ham, r_lazy)
        eager_ham = express(ham, r_eager)
        @test lazy_ham isa LazySum
        @test isapprox(dense(lazy_ham), eager_ham)
    end

    # LazyProduct from symbolic operator multiplication
    @testset "LazyProduct" begin
        op = X * Z
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)
        @test lazy_op isa LazyProduct
        @test isapprox(dense(lazy_op), eager_op)

        # Product of tensor products
        prod_op = tensor(X, IdentityOp(X)) * tensor(IdentityOp(X), Z)
        lazy_prod = express(prod_op, r_lazy)
        eager_prod = express(prod_op, r_eager)
        @test lazy_prod isa LazyProduct
        @test isapprox(dense(lazy_prod), eager_prod)
    end

    # LazyTensor from symbolic tensor products
    @testset "LazyTensor" begin
        op = tensor(X, Z)
        lazy_op = express(op, r_lazy)
        eager_op = express(op, r_eager)
        @test lazy_op isa LazyTensor
        @test isapprox(dense(lazy_op), eager_op)

        # Tensor with identity (should filter identity out in LazyTensor)
        op2 = tensor(X, IdentityOp(X))
        lazy_op2 = express(op2, r_lazy)
        eager_op2 = express(op2, r_eager)
        @test lazy_op2 isa LazyTensor
        @test isapprox(dense(lazy_op2), eager_op2)
    end

    # Commutator
    @testset "Commutator" begin
        c = commutator(X, Z)
        lazy_c = express(c, r_lazy)
        eager_c = express(c, r_eager)
        @test lazy_c isa LazySum
        @test isapprox(dense(lazy_c), eager_c)
    end

    # Anticommutator
    @testset "Anticommutator" begin
        ac = anticommutator(X, Z)
        lazy_ac = express(ac, r_lazy)
        eager_ac = express(ac, r_eager)
        @test lazy_ac isa LazySum
        @test isapprox(dense(lazy_ac), eager_ac)
    end

    # Cutoff still applies to Fock-space objects with lazy=true
    @testset "Cutoff with lazy" begin
        r_lazy4 = QuantumOpticsRepr(cutoff=4, lazy=true)
        op = N + Create
        lazy_op = express(op, r_lazy4)
        eager_op = express(op, QuantumOpticsRepr(cutoff=4))
        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), eager_op)
    end

    # Eager mode is unchanged
    @testset "Eager unchanged" begin
        op = X + Z
        eager_op = express(op, r_eager)
        @test !(eager_op isa LazySum)

        prod_op = X * Z
        eager_prod = express(prod_op, r_eager)
        @test !(eager_prod isa LazyProduct)
    end

    # Minimal example from the issue
    @testset "Issue minimal example" begin
        op = tensor(X, IdentityOp(X)) + tensor(IdentityOp(X), Z)
        eager_op = express(op, QuantumOpticsRepr())
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), eager_op)

        prod_op = tensor(X, IdentityOp(X)) * tensor(IdentityOp(X), Z)
        lazy_prod = express(prod_op, r_lazy)
        @test lazy_prod isa LazyProduct
        @test isapprox(dense(lazy_prod), express(prod_op, QuantumOpticsRepr()))
    end
end