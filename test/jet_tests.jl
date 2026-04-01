@testitem "JET checks" tags=[:jet] begin
    using JET
    using QuantumOptics, QuantumClifford # to load the extensions
    using Test
    using QuantumSymbolics

    rep = JET.report_package(QuantumSymbolics, target_modules=[QuantumSymbolics])
    @show rep
    @test_broken length(JET.get_reports(rep)) == 0
    @test length(JET.get_reports(rep)) <= 6
end
