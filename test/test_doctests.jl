@testitem "Doctests" tags=[:doctests, :clifford] begin
    using Pkg
    if get(Pkg.project().dependencies, "QuantumClifford", nothing) === nothing
        @test_skip "QuantumClifford not present in the test environment"
        return
    end
    using Documenter
    using QuantumOptics
    try
        using QuantumClifford
    catch
        @test_skip "QuantumClifford not available in test environment"
        return
    end

    DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford); recursive=true)
    doctest(QuantumSymbolics)
end
