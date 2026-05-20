using Test
using QuantumSymbolics
using QuantumSymbolics: Metadata

@testset "Inhomogeneous expression field types" begin
    @op A
    @ket k
    @bra b

    apply_ket = A * k
    apply_bra = b * A
    braket = b * k
    outer = k * b

    @test fieldtype(typeof(apply_ket), :op) === typeof(A)
    @test fieldtype(typeof(apply_ket), :ket) === typeof(k)
    @test fieldtype(typeof(apply_bra), :bra) === typeof(b)
    @test fieldtype(typeof(apply_bra), :op) === typeof(A)
    @test fieldtype(typeof(braket), :bra) === typeof(b)
    @test fieldtype(typeof(braket), :ket) === typeof(k)
    @test fieldtype(typeof(outer), :ket) === typeof(k)
    @test fieldtype(typeof(outer), :bra) === typeof(b)

    for expr in (apply_ket, apply_bra, braket, outer)
        @test fieldtype(typeof(expr), :metadata) === Metadata
        @test all(name -> fieldtype(typeof(expr), name) !== Any, fieldnames(typeof(expr)))
    end
end
