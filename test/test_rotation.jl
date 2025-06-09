@testitem "Test Rotation" begin
    @testset "Identity tests" begin
        @test isequal(Rx(0), I)
        @test isequal(Ry(0), I)
        @test isequal(Rz(0), I)
    end

    @testset "Pauli tests" begin
        @test isequal(qsimplify(Rx(π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(Ry(π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(Rz(π), rewriter=qsimplify_rot), -im*Z)

        @test isequal(qsimplify(Rx(1π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(Ry(1π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(Rz(1π), rewriter=qsimplify_rot), -im*Z)
    end

    @testset "Fusion tests" begin 
        @test isequal(qsimplify(Rx(π/3) * Rx(π/3), rewriter=qsimplify_rot), Rx(2π/3))
        @test isequal(qsimplify(Ry(π/3) * Ry(π/3), rewriter=qsimplify_rot), Ry(2π/3))
        @test isequal(qsimplify(Rz(π/3) * Rz(π/3), rewriter=qsimplify_rot), Rz(2π/3))

        @test isequal(qsimplify(Rx(π/2) * Rx(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(π/2) * Ry(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(π/2) * Rz(-π/2), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * Rx(π/2) * Rx(π/2), rewriter=qsimplify_rot), -2im*X)
        @test isequal(qsimplify(2 * Ry(π/2) * Ry(π/2), rewriter=qsimplify_rot), -2im*Y)
        @test isequal(qsimplify(2 * Rz(π/2) * Rz(π/2), rewriter=qsimplify_rot), -2im*Z)
    end

    @testset "Modulo tests" begin
        @test isequal(qsimplify(Rx(2π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(Ry(2π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(Rz(2π), rewriter=qsimplify_rot), -I)

        @test isequal(qsimplify(Rx(3π), rewriter=qsimplify_rot), im*X)
        @test isequal(qsimplify(Ry(3π), rewriter=qsimplify_rot), im*Y)
        @test isequal(qsimplify(Rz(3π), rewriter=qsimplify_rot), im*Z)

        @test isequal(qsimplify(Rx(4π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(4π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(4π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(Rx(5π), rewriter=qsimplify_rot), -im*X)
        @test isequal(qsimplify(Ry(5π), rewriter=qsimplify_rot), -im*Y)
        @test isequal(qsimplify(Rz(5π), rewriter=qsimplify_rot), -im*Z)

        @test isequal(qsimplify(Rx(π) * Rx(π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(Ry(π) * Ry(π), rewriter=qsimplify_rot), -I)
        @test isequal(qsimplify(Rz(π) * Rz(π), rewriter=qsimplify_rot), -I)

        @test isequal(qsimplify(2 * Rx(3π/2) * Rx(2π/2), rewriter=qsimplify_rot), -2Rx(π/2))
        @test isequal(qsimplify(2 * Ry(3π/2) * Ry(2π/2), rewriter=qsimplify_rot), -2Ry(π/2))
        @test isequal(qsimplify(2 * Rz(3π/2) * Rz(2π/2), rewriter=qsimplify_rot), -2Rz(π/2))
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