@testitem "Test Ration" begin
    @testset "Identity tests" begin
        @test isequal(qsimplify(Rx(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(0), rewriter=qsimplify_rot), I)
    end

    @testset "Fusion tests" begin 
        @test isequal(qsimplify(Rx(π/2) * Rx(π/2), rewriter=qsimplify_rot), Rx(1π))
        @test isequal(qsimplify(Ry(π/2) * Ry(π/2), rewriter=qsimplify_rot), Ry(1π))
        @test isequal(qsimplify(Rz(π/2) * Rz(π/2), rewriter=qsimplify_rot), Rz(1π))

        @test isequal(qsimplify(Rx(π/2) * Rx(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(π/2) * Ry(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(π/2) * Rz(-π/2), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * Rx(π/2) * Rx(π/2), rewriter=qsimplify_rot), 2Rx(1π))
        @test isequal(qsimplify(2 * Ry(π/2) * Ry(π/2), rewriter=qsimplify_rot), 2Ry(1π))
        @test isequal(qsimplify(2 * Rz(π/2) * Rz(π/2), rewriter=qsimplify_rot), 2Rz(1π))
    end

    @testset "Modulo tests" begin
        @test isequal(qsimplify(Rx(2π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(2π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(2π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(Rx(π) * Rx(π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Ry(π) * Ry(π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(Rz(π) * Rz(π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * Rx(3π/2) * Rx(2π/2), rewriter=qsimplify_rot), 2Rx(π/2))
        @test isequal(qsimplify(2 * Ry(3π/2) * Ry(2π/2), rewriter=qsimplify_rot), 2Ry(π/2))
        @test isequal(qsimplify(2 * Rz(3π/2) * Rz(2π/2), rewriter=qsimplify_rot), 2Rz(π/2))
    end

    @testset "Exponential tests" begin
        @test isequal(qsimplify(exp(-im * π/2 * X), rewriter=qsimplify_rot), Rx(1π))
        @test isequal(qsimplify(exp(-im * π/2 * Y), rewriter=qsimplify_rot), Ry(1π))
        @test isequal(qsimplify(exp(-im * π/2 * Z), rewriter=qsimplify_rot), Rz(1π))

        @test isequal(qsimplify(exp(-im * 2π/2 * X) * exp(-im * π/2 * X), rewriter=qsimplify_rot), Rx(1π))
        @test isequal(qsimplify(exp(-im * 2π/2 * Y) * exp(-im * π/2 * Y), rewriter=qsimplify_rot), Ry(1π))
        @test isequal(qsimplify(exp(-im * 2π/2 * Z) * exp(-im * π/2 * Z), rewriter=qsimplify_rot), Rz(1π))
    end
end