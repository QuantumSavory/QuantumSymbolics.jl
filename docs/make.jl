using Revise # for interactive work on docs
push!(LOAD_PATH,"../src/")

using Documenter
using DocumenterCitations
using QuantumSymbolics
using QuantumInterface
using LinearAlgebra

DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford, QuantumInterface, LinearAlgebra); recursive=true)

function main()
    bib = CitationBibliography(joinpath(@__DIR__,"src/references.bib"), style=:authoryear)

    makedocs(
    plugins=[bib],
    doctest = false,
    clean = true,
    sitename = "QuantumSymbolics.jl",
    format = Documenter.HTML(
        assets=["assets/init.js"]
    ),
    modules = [QuantumSymbolics, QuantumInterface],
    checkdocs = :exports,
    warnonly = false,
    authors = "Stefan Krastanov",
    pages = [
        "QuantumSymbolics.jl" => "index.md",
        "Getting Started with QuantumSymbolics.jl" => "introduction.md",
        "Express Functionality" => "express.md",
        "Qubit Basis Choice" => "qubit_basis.md",
        "Quantum Harmonic Oscillators" => "QHO.md",
        "API" => "API.md",
    ]
    )

    deploydocs(
        repo = "github.com/QuantumSavory/QuantumSymbolics.jl.git"
    )
end

main()
