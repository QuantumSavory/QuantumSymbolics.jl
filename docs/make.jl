using Revise # for interactive work on docs
push!(LOAD_PATH,"../src/")

using Documenter
using AnythingLLMDocs
using QuantumSymbolics
using QuantumInterface
using LinearAlgebra

DocMeta.setdocmeta!(QuantumSymbolics, :DocTestSetup, :(using QuantumSymbolics, QuantumOptics, QuantumClifford, QuantumInterface, LinearAlgebra); recursive=true)

function main()
    doc_modules = [QuantumSymbolics, QuantumInterface]
    api_base="https://anythingllm.krastanov.org/api/v1"
    anythingllm_assets = integrate_anythingllm(
        "QuantumSymbolics",
        doc_modules,
        @__DIR__,
        api_base;
        repo = "github.com/QuantumSavory/QuantumSymbolics.jl.git",
        options = EmbedOptions(),
    )

    assets = Any["assets/init.js"]
    append!(assets, anythingllm_assets)

    makedocs(
    doctest = false,
    clean = true,
    sitename = "QuantumSymbolics.jl",
    format = Documenter.HTML(
        assets=assets
    ),
    modules = doc_modules,
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
