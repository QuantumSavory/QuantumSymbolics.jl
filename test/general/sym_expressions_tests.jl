using Test
using QuantumSymbolics
using TermInterface: arguments, maketerm, metadata, operation

@testset "Sym expressions" begin
    @test +(Z1) == Z1
    @test +(Z) == Z
    @test isequal(Z1 - Z2, Z1 + (-Z2))
    @test isequal(Z1 - 2*Z2 + 2*X1, -2*Z2 + Z1 + 2*X1)
    @test isequal(Z1 - 2*Z2 + 2*X1, Z1 + 2*(-Z2+X1))

    state1 = XBasisState(1, SpinBasis(1//2))
    state2 = XBasisState(1, SpinBasis(1//2))
    state3 = XBasisState(2, SpinBasis(1//2))

    @test isequal(state1, state2)
    @test !isequal(state1, state3)

    @op A
    @op B

    @test isequal(A+B+A, 2A+B)
    @test isequal(A+B-A, B)
    @test A+B-A === B
    @test 0*A === A-A-2A+2A
    @test isequal(A+B-A+B, 2B)
    @test isequal(2A-3B+2(A+B), 4A-B)
    @test isequal(2A-3B+2(A+2B), 4A+B)

    @testset "typed symbolic operation reconstruction" begin
        trace_a = tr(A)
        trace_b = tr(B)

        for scalar_expr in (2 * trace_a, trace_a + trace_b, trace_a * trace_b)
            rebuilt = maketerm(
                typeof(scalar_expr),
                operation(scalar_expr),
                arguments(scalar_expr),
                metadata(scalar_expr),
            )
            @test isequal(rebuilt, scalar_expr)
        end

        @test isequal(SMulOperator(A, B), A * B)
    end
end
