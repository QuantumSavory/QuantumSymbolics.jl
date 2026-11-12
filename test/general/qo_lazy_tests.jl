using Test
using QuantumSymbolics

@testset "Lazy QuantumOpticsRepr" begin
    using QuantumOptics

    r_lazy = QuantumOpticsRepr(lazy=true)

    @testset "constructor" begin
        @test QuantumOpticsRepr().lazy == false
        @test QuantumOpticsRepr(cutoff=4).lazy == false
        @test QuantumOpticsRepr(4).lazy == false
        @test QuantumOpticsRepr(lazy=true).lazy == true
        @test QuantumOpticsRepr(cutoff=4, lazy=true).cutoff == 4
        @test QuantumOpticsRepr(cutoff=4, lazy=true).lazy == true
    end

    Id = IdentityOp(X1)

    @testset "LazySum from operator sum" begin
        op = tensor(X, Id) + tensor(Id, Z)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "LazySum with scalar coefficients" begin
        op = 2*tensor(X, Id) + 3*tensor(Id, Z)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazySum
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "LazyProduct from operator product" begin
        op = tensor(X, Id) * tensor(Id, Z)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazyProduct
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "LazyTensor from tensor product" begin
        op = tensor(X, Z)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazyTensor
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "LazyTensor three subsystems" begin
        op = tensor(X, Z, Y)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazyTensor
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "sum of tensor products gives LazySum of LazyTensors" begin
        op = tensor(X, Id) + tensor(Id, Z)
        lazy_op = express(op, r_lazy)
        @test lazy_op isa LazySum
        @test all(o isa LazyTensor for o in lazy_op.operators)
        @test isapprox(dense(lazy_op), express(op, QuantumOpticsRepr()))
    end

    @testset "lazy=false keeps eager behavior" begin
        op = tensor(X, Id) + tensor(Id, Z)
        @test express(op, QuantumOpticsRepr()) isa QuantumOpticsBase.Operator
        @test express(op, QuantumOpticsRepr(lazy=false)) isa QuantumOpticsBase.Operator
    end

    @testset "cutoff still applies with lazy=true" begin
        lazy_fock = QuantumOpticsRepr(cutoff=4, lazy=true)
        @test express(N, lazy_fock) isa QuantumOpticsBase.Operator
        @test size(dense(express(N, lazy_fock)).data) == (5, 5)
    end
end
