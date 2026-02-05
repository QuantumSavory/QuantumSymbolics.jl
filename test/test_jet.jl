@testitem "JET checks" tags=[:jet] begin
    using JET
    using Test
    using PBCCompiler

    rep = JET.report_package(PBCCompiler, target_modules=[PBCCompiler])
    @show rep
    @test_broken length(JET.get_reports(rep)) == 0
    @test length(JET.get_reports(rep)) <= 6
end
