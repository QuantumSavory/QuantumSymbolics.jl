@testitem "Test Rotation" begin
    @testset "express tests" begin
        using QuantumOptics
        b = SpinBasis(1//2)

        @test isapprox(express(RotXGate(π/2)), Operator(b, [1 -im; -im 1]/√2))
        @test isapprox(express(RotYGate(π/2)), Operator(b, [1 -1; 1 1]/√2))
        @test isapprox(express(RotZGate(π/2)), Operator(b, [1-im 0; 0 1+im]/√2))
    end

    @testset "Identity tests" begin
        @test isequal(qsimplify(RotXGate(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotYGate(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZGate(0), rewriter=qsimplify_rot), I)
    end

    @testset "Pauli tests" begin
        @test isequal(qsimplify(RotXGate(π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(RotYGate(π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(RotZGate(π), rewriter=qsimplify_rot), -im*Z)

        @test isequal(qsimplify(RotXGate(1π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(RotYGate(1π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(RotZGate(1π), rewriter=qsimplify_rot), -im*Z)
    end

    @testset "Fusion tests" begin 
        @test isequal(qsimplify(RotXGate(π/3) * RotXGate(π/3), rewriter=qsimplify_rot), RotXGate(2π/3))
        @test isequal(qsimplify(RotYGate(π/3) * RotYGate(π/3), rewriter=qsimplify_rot), RotYGate(2π/3))
        @test isequal(qsimplify(RotZGate(π/3) * RotZGate(π/3), rewriter=qsimplify_rot), RotZGate(2π/3))

        @test isequal(qsimplify(RotXGate(π/2) * RotXGate(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotYGate(π/2) * RotYGate(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZGate(π/2) * RotZGate(-π/2), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * RotXGate(π/2) * RotXGate(π/2), rewriter=qsimplify_rot), -2im*X)
        @test isequal(qsimplify(2 * RotYGate(π/2) * RotYGate(π/2), rewriter=qsimplify_rot), -2im*Y)
        @test isequal(qsimplify(2 * RotZGate(π/2) * RotZGate(π/2), rewriter=qsimplify_rot), -2im*Z)
    end

    @testset "Modulo tests" begin
        @test isequal(qsimplify(RotXGate(2π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(RotYGate(2π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(RotZGate(2π), rewriter=qsimplify_rot), -I)

        @test isequal(qsimplify(RotXGate(3π), rewriter=qsimplify_rot), im*X)
        @test isequal(qsimplify(RotYGate(3π), rewriter=qsimplify_rot), im*Y)
        @test isequal(qsimplify(RotZGate(3π), rewriter=qsimplify_rot), im*Z)

        @test isequal(qsimplify(RotXGate(4π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotYGate(4π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZGate(4π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(RotXGate(5π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(RotYGate(5π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(RotZGate(5π), rewriter=qsimplify_rot), -im*Z)

        @test isequal(qsimplify(RotXGate(π) * RotXGate(π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(RotYGate(π) * RotYGate(π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(RotZGate(π) * RotZGate(π), rewriter=qsimplify_rot), -I)

        @test isequal(qsimplify(2 * RotXGate(3π/2) * RotXGate(2π/2), rewriter=qsimplify_rot), -2RotXGate(π/2))
        @test isequal(qsimplify(2 * RotYGate(3π/2) * RotYGate(2π/2), rewriter=qsimplify_rot), -2RotYGate(π/2))
        @test isequal(qsimplify(2 * RotZGate(3π/2) * RotZGate(2π/2), rewriter=qsimplify_rot), -2RotZGate(π/2))
    end

    @testset "Exponential tests" begin
        @test isequal(qsimplify(exp(-im * π/2 * X), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(exp(-im * π/2 * Y), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(exp(-im * π/2 * Z), rewriter=qsimplify_rot), -im*Z)

        @test isequal(qsimplify(2 * exp(-im * 2π/2 * X) * exp(-im * 5π/2 * X), rewriter=qsimplify_rot), 2im*X)
        @test isequal(qsimplify(2 * exp(-im * 2π/2 * Y) * exp(-im * 5π/2 * Y), rewriter=qsimplify_rot), 2im*Y)
        @test isequal(qsimplify(2 * exp(-im * 2π/2 * Z) * exp(-im * 5π/2 * Z), rewriter=qsimplify_rot), 2im*Z)
    end
end