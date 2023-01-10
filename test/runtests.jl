using SafeTestsets
using QuantumSymbolics
using QSymbolicsBase

function doset(descr)
    if length(ARGS) == 0
        return true
    end
    for a in ARGS
        if occursin(lowercase(a), lowercase(descr))
            return true
        end
    end
    return false
end

macro doset(descr)
    quote
        if doset($descr)
            @safetestset $descr begin include("test_"*$descr*".jl") end
        end
    end
end

println("Starting tests with $(Threads.nthreads()) threads out of `Sys.CPU_THREADS = $(Sys.CPU_THREADS)`...")

@doset "sym_expressions"
@doset "express_opt"
@doset "express_cliff"
@doset "qo"
@doset "qo_qc_interop"

VERSION == v"1.8" && @doset "doctests"

get(ENV,"QSYMBOLICS_JET_TEST","")=="true" && @doset "jet"
@doset "aqua"
