using TestItemRunner
using QuantumSymbolics

# filter for the test
testfilter = ti -> begin
  exclude = Symbol[:jet, :clifford]
  if !(VERSION >= v"1.10")
    push!(exclude, :doctests)
    push!(exclude, :aqua)
  end

  return all(!in(exclude), ti.tags)
end

println("Starting tests with $(Threads.nthreads()) threads out of `Sys.CPU_THREADS = $(Sys.CPU_THREADS)`...")

@run_package_tests filter=testfilter

if get(ENV,"JET_TEST","")=="true"
    @run_package_tests filter=(ti -> :jet in ti.tags)
end
