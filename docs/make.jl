using Revise # for interactive work on docs
push!(LOAD_PATH,"../src/")

using Documenter
using DocumenterCitations
using QuantumSymbolics
using QuantumOptics
using QuantumClifford

DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford); recursive=true)

function main()
    bib = CitationBibliography(joinpath(@__DIR__,"src/references.bib"), style=:authoryear)
    makedocs(
    bib,
    doctest = false,
    strict = Documenter.except(:missing_docs),
    clean = true,
    sitename = "QuantumSymbolics.jl",
    format = Documenter.HTML(
        assets=["assets/init.js"]
    ),
    modules = [QuantumSymbolics],
    authors = "Stefan Krastanov",
    pages = [
        "QuantumSymbolics.jl" => "index.md",
        "Qubit Basis Choice" => "qubit_basis.md",
        "API" => "API.md",
    ]
    )

    deploydocs(
        repo = "github.com/QuantumSavory/QuantumSymbolics.jl.git"
    )
end

main()
