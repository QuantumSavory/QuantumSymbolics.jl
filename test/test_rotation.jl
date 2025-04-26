@testitem "Test Rotation" begin
    @testset "Identity tests" begin
        @test isequal(qsimplify(RotX(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotY(0), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZ(0), rewriter=qsimplify_rot), I)
    end

    @testset "Fusion tests" begin 
        @test isequal(qsimplify(RotX(π/2) * RotX(π/2), rewriter=qsimplify_rot), RotX(1π))
        @test isequal(qsimplify(RotY(π/2) * RotY(π/2), rewriter=qsimplify_rot), RotY(1π))
        @test isequal(qsimplify(RotZ(π/2) * RotZ(π/2), rewriter=qsimplify_rot), RotZ(1π))

        @test isequal(qsimplify(RotX(π/2) * RotX(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotY(π/2) * RotY(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZ(π/2) * RotZ(-π/2), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * RotX(π/2) * RotX(π/2), rewriter=qsimplify_rot), 2RotX(1π))
        @test isequal(qsimplify(2 * RotY(π/2) * RotY(π/2), rewriter=qsimplify_rot), 2RotY(1π))
        @test isequal(qsimplify(2 * RotZ(π/2) * RotZ(π/2), rewriter=qsimplify_rot), 2RotZ(1π))
    end

    @testset "Modulo tests" begin
        @test isequal(qsimplify(RotX(2π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotY(2π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZ(2π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(RotX(π) * RotX(π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotY(π) * RotY(π), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZ(π) * RotZ(π), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * RotX(3π/2) * RotX(2π/2), rewriter=qsimplify_rot), 2RotX(π/2))
        @test isequal(qsimplify(2 * RotY(3π/2) * RotY(2π/2), rewriter=qsimplify_rot), 2RotY(π/2))
        @test isequal(qsimplify(2 * RotZ(3π/2) * RotZ(2π/2), rewriter=qsimplify_rot), 2RotZ(π/2))
    end

    @testset "Exponential tests" begin
        @test isequal(qsimplify(exp(-im * π/2 * X), rewriter=qsimplify_rot), RotX(1π))
        @test isequal(qsimplify(exp(-im * π/2 * Y), rewriter=qsimplify_rot), RotY(1π))
        @test isequal(qsimplify(exp(-im * π/2 * Z), rewriter=qsimplify_rot), RotZ(1π))

        @test isequal(qsimplify(exp(-im * 2π/2 * X) * exp(-im * π/2 * X), rewriter=qsimplify_rot), RotX(1π))
        @test isequal(qsimplify(exp(-im * 2π/2 * Y) * exp(-im * π/2 * Y), rewriter=qsimplify_rot), RotY(1π))
        @test isequal(qsimplify(exp(-im * 2π/2 * Z) * exp(-im * π/2 * Z), rewriter=qsimplify_rot), RotZ(1π))
    end
end