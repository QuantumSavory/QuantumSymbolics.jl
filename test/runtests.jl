using SafeTestsets
using QuantumSymbolics

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
@doset "basis_consistency"
@doset "superop"
@doset "conditional_cliffords"
@doset "commutator"
@doset "anticommutator"
@doset "dagger"
@doset "zero_obj"
@doset "expand"
@doset "pauli"

VERSION >= v"1.9" && @doset "doctests"
get(ENV,"JET_TEST","")=="true" && @doset "jet"
VERSION >= v"1.9" && @doset "aqua"
