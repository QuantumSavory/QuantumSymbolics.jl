@testitem "Test Rotation" begin
    @testset "Identity tests" begin
        @test isequal(qsimplify(RotX(0), rewriter=qsimplify_rot), I)
    end

    @testset "Fusion tests" begin 
        @test isequal(qsimplify(RotX(π/2) * RotX(π/2), rewriter=qsimplify_rot), RotX(1π))
        @test isequal(qsimplify(RotY(π/2) * RotY(π/2), rewriter=qsimplify_rot), RotY(1π))
        @test isequal(qsimplify(RotZ(π/2) * RotZ(π/2), rewriter=qsimplify_rot), RotZ(1π))

        @test isequal(qsimplify(RotX(π/2) * RotX(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotY(π/2) * RotY(-π/2), rewriter=qsimplify_rot), I)
        @test isequal(qsimplify(RotZ(π/2) * RotZ(-π/2), rewriter=qsimplify_rot), I)

        @test isequal(qsimplify(2 * RotX(π) * RotX(π), rewriter=qsimplify_rot), 2RotX(2π))
        @test isequal(qsimplify(2 * RotY(π) * RotY(π), rewriter=qsimplify_rot), 2RotY(2π))
        @test isequal(qsimplify(2 * RotZ(π) * RotZ(π), rewriter=qsimplify_rot), 2RotZ(2π))
    end

    @testset "Exponential tests" begin
        @test isequal(qsimplify(exp(-im * π/2 * X), rewriter=qsimplify_rot), RotX(π))
        @test isequal(qsimplify(exp(-im * π/2 * Y), rewriter=qsimplify_rot), RotY(π))
        @test isequal(qsimplify(exp(-im * π/2 * Z), rewriter=qsimplify_rot), RotZ(π))
    end

    @testset "modulo tests" 
end