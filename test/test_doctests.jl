using Documenter
using QuantumSymbolics
using QuantumOptics
using QuantumClifford
using Test

function doctests()
    @testset "Doctests" begin
        DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford); recursive=true)
        doctest(QuantumSymbolics)
    end
end

doctests()
