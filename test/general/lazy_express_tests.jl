using Test
using QuantumSymbolics

@testset "Lazy QuantumOpticsRepr expressions" begin
    using QuantumOptics

    eager = QuantumOpticsRepr()
    lazy = QuantumOpticsRepr(lazy=true)

    @testset "constructors preserved" begin
        @test QuantumOpticsRepr().lazy == false
        @test QuantumOpticsRepr(4).cutoff == 4
        @test QuantumOpticsRepr(4).lazy == false
        @test QuantumOpticsRepr(cutoff=4, lazy=true).lazy == true
    end

    @testset "sums" begin
        op = X + Y + Z
        @test express(op, lazy) isa LazySum
        @test isapprox(dense(express(op, lazy)), express(op, eager))
    end

    @testset "scaled sums keep coefficients in the factors" begin
        op = 2*X + 3*Y
        lz = express(op, lazy)
        @test lz isa LazySum
        @test Set(Complex.(lz.factors)) == Set([2.0 + 0im, 3.0 + 0im])
        @test isapprox(dense(lz), express(op, eager))
    end

    @testset "products" begin
        op = X * Y
        @test express(op, lazy) isa LazyProduct
        @test isapprox(dense(express(op, lazy)), express(op, eager))
    end

    @testset "tensor products" begin
        op = tensor(X, Y)
        @test express(op, lazy) isa LazyTensor
        @test isapprox(dense(express(op, lazy)), express(op, eager))
    end

    @testset "lazy tensors omit implied identities" begin
        lt = express(tensor(X, I), lazy)
        @test lt isa LazyTensor
        @test length(lt.operators) == 1   # the identity subsystem is left implicit
        @test isapprox(dense(lt), express(tensor(X, I), eager))

        lt2 = express(tensor(I, Z), lazy)
        @test lt2 isa LazyTensor
        @test length(lt2.operators) == 1
        @test lt2.indices == [2]
        @test isapprox(dense(lt2), express(tensor(I, Z), eager))
    end

    @testset "sums and products of tensors" begin
        op = tensor(X, I) + tensor(I, Z)
        lz = express(op, lazy)
        @test lz isa LazySum
        @test isapprox(dense(lz), express(op, eager))

        prod_op = tensor(X, I) * tensor(I, Z)
        lp = express(prod_op, lazy)
        @test lp isa LazyProduct
        @test isapprox(dense(lp), express(prod_op, eager))
    end

    @testset "commutators and anticommutators" begin
        σx, σy = express(X, eager), express(Y, eager)
        @test express(commutator(X, Y), lazy) isa LazySum
        @test isapprox(dense(express(commutator(X, Y), lazy)), dense(σx*σy - σy*σx))
        @test isapprox(dense(express(anticommutator(X, Y), lazy)), dense(σx*σy + σy*σx))
    end

    @testset "tensor falls back to eager when a factor spans several subsystems" begin
        op = tensor(CNOT, X)
        lz = express(op, lazy)
        @test !(lz isa LazyTensor)
        @test isapprox(dense(lz), express(op, eager))
    end

    @testset "cutoff still applies with lazy" begin
        r = QuantumOpticsRepr(cutoff=4, lazy=true)
        lz = express(Create + Destroy, r)
        @test lz isa LazySum
        @test basis(lz) == FockBasis(4)
        @test isapprox(dense(lz), express(Create + Destroy, QuantumOpticsRepr(cutoff=4)))
    end

    @testset "default representation stays eager" begin
        @test express(X + Y, eager) isa Operator
        @test express(X + Y, QuantumOpticsRepr(2, false)) isa Operator
    end
end
