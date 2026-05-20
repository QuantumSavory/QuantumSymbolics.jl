using Test
using QuantumSymbolics

@testset "Literal quantum object field types" begin
    constructors = (
        SBra,
        SKet,
        SOperator,
        SHermitianOperator,
        SUnitaryOperator,
        SHermitianUnitaryOperator,
        SSuperOperator,
    )
    bases = (SpinBasis(1//2), FockBasis(3))

    for constructor in constructors
        obj = constructor(:x)

        @test fieldtype(typeof(obj), :basis) === typeof(SpinBasis(1//2))
        @test isconcretetype(fieldtype(typeof(obj), :basis))
        @test basis(obj) == SpinBasis(1//2)
    end

    for constructor in constructors, b in bases
        obj = constructor(:x, b)

        @test fieldtype(typeof(obj), :name) === Symbol
        @test fieldtype(typeof(obj), :basis) === typeof(b)
        @test isconcretetype(fieldtype(typeof(obj), :basis))
        @test basis(obj) == b
    end
end
