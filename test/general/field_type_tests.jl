using Test
using QuantumSymbolics
using QuantumSymbolics: Metadata

@testset "Inhomogeneous expression field types" begin
    @op A
    @ket k
    @bra b

    exprs = (A * k, b * A, b * k, k * b)

    for expr in exprs
        @test getfield(expr, :metadata) isa Metadata
        for field in fieldnames(typeof(expr))
            @test isconcretetype(fieldtype(typeof(expr), field))
        end
    end

    @test A * k isa SApplyKet{typeof(A),typeof(k)}
    @test b * A isa SApplyBra{typeof(b),typeof(A)}
    @test b * k isa SBraKet{typeof(b),typeof(k)}
    @test k * b isa SOuterKetBra{typeof(k),typeof(b)}

    @test isequal(A * k, SApplyKet(A, k))
    @test isequal(b * A, SApplyBra(b, A))
    @test isequal(b * k, SBraKet(b, k))
    @test isequal(k * b, SOuterKetBra(k, b))
end
