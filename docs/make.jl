using Revise # for interactive work on docs
push!(LOAD_PATH,"../src/")

using Documenter
using DocumenterCitations
using QuantumSymbolics
using QSymbolicsBase
using QSymbolicsClifford
using QSymbolicsOptics

DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QSymbolicsBase, QSymbolicsClifford, QSymbolicsOptics); recursive=true)

function main()
    bib = CitationBibliography(joinpath(@__DIR__,"src/references.bib"))
    makedocs(
    bib,
    doctest = false,
    clean = true,
    sitename = "QuantumSymbolics.jl",
    format = Documenter.HTML(
        assets=["assets/init.js"]
    ),
    modules = [QuantumSymbolics, QSymbolicsBase, QSymbolicsClifford, QSymbolicsOptics],
    authors = "Stefan Krastanov",
    pages = [
        "QuantumSymbolics.jl" => "index.md",
        "Qubit Basis Choice" => "qubit_basis.md",
        "API" => "API.md",
    ]
    )

    deploydocs(
        repo = "github.com/Krastanov/QuantumSymbolics.jl.git"
    )
end

main()
