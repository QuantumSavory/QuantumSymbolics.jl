@testset "Doctests" begin
    using Documenter
    using QuantumOptics
    using QuantumClifford

    DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford); recursive=true)
    doctest(QuantumSymbolics)
end