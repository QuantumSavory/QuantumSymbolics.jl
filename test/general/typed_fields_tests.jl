using Test
using QuantumSymbolics
using TermInterface: arguments, maketerm, metadata, operation

@testset "Typed symbolic expression fields" begin
    @op A
    @ket k
    @bra b

    apply_ket = A * k
    @test apply_ket isa SApplyKet{typeof(A),typeof(k)}
    @test fieldtype(typeof(apply_ket), :op) === typeof(A)
    @test fieldtype(typeof(apply_ket), :ket) === typeof(k)
    @test isequal(
        maketerm(typeof(apply_ket), operation(apply_ket), arguments(apply_ket), metadata(apply_ket)),
        apply_ket
    )

    apply_bra = b * A
    @test apply_bra isa SApplyBra{typeof(b),typeof(A)}
    @test fieldtype(typeof(apply_bra), :bra) === typeof(b)
    @test fieldtype(typeof(apply_bra), :op) === typeof(A)
    @test isequal(
        maketerm(typeof(apply_bra), operation(apply_bra), arguments(apply_bra), metadata(apply_bra)),
        apply_bra
    )

    inner_product = b * k
    @test inner_product isa SBraKet{typeof(b),typeof(k)}
    @test fieldtype(typeof(inner_product), :bra) === typeof(b)
    @test fieldtype(typeof(inner_product), :ket) === typeof(k)
    @test isequal(
        maketerm(typeof(inner_product), operation(inner_product), arguments(inner_product), metadata(inner_product)),
        inner_product
    )

    outer = k * b
    @test outer isa SOuterKetBra{typeof(k),typeof(b)}
    @test fieldtype(typeof(outer), :ket) === typeof(k)
    @test fieldtype(typeof(outer), :bra) === typeof(b)
    @test isequal(
        maketerm(typeof(outer), operation(outer), arguments(outer), metadata(outer)),
        outer
    )
end
