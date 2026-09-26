using Test
using QuantumSymbolics

@testset "Express lazy (QuantumOpticsRepr(lazy=true))" begin
    import QuantumOptics
    using QuantumOptics: LazySum, LazyProduct, LazyTensor, dense

    eager = QuantumOpticsRepr()
    lazy  = QuantumOpticsRepr(lazy=true)

    # constructor + backward compatibility
    @test QuantumOpticsRepr().lazy == false
    @test QuantumOpticsRepr(3).cutoff == 3          # historical positional ctor
    @test QuantumOpticsRepr(lazy=true).lazy == true

    # symbolic sum -> LazySum
    s = express(X + Y, lazy)
    @test s isa LazySum
    @test isapprox(dense(s), express(X + Y, eager))

    # symbolic product -> LazyProduct
    p = express(X * Y, lazy)
    @test p isa LazyProduct
    @test isapprox(dense(p), express(X * Y, eager))

    # symbolic tensor product -> LazyTensor
    t = express(X ⊗ Y, lazy)
    @test t isa LazyTensor
    @test isapprox(dense(t), express(X ⊗ Y, eager))

    # scalar prefactors and nesting remain numerically correct
    @test isapprox(dense(express(2 * X + Y, lazy)), express(2 * X + Y, eager))
    @test isapprox(dense(express((X + Y) ⊗ Z, lazy)), express((X + Y) ⊗ Z, eager))

    # the default (eager) representation is unchanged
    @test !(express(X + Y, eager) isa LazySum)
end
