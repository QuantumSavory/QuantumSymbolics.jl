using QuantumSymbolics
using TestItemRunner

JET_flag = false

if get(ENV, "JET_TEST", "") != "true"
    @info "Skipping JET tests -- must be explicitly enabled."
    @info "Environment must set JET_TEST=true."
else
    JET_flag = true
end

using Pkg
JET_flag && Pkg.add("JET")

# filter for the test
testfilter = ti -> begin
    exclude = Symbol[]
    if !JET_flag
        push!(exclude, :jet)
    end
    if !(VERSION >= v"1.10")
        push!(exclude, :doctests)
        push!(exclude, :aqua)
    end

    return all(!in(exclude), ti.tags)
end

println("Starting tests with $(Threads.nthreads()) threads out of `Sys.CPU_THREADS = $(Sys.CPU_THREADS)`...")

@run_package_tests filter=testfilter