using ParallelTestRunner

const TEST_PROJECTS = Dict(
    "jet" => normpath(joinpath(@__DIR__, "projects", "jet")),
)
const JET_TEST_PATH = joinpath(@__DIR__, "jet_tests.jl")

args = isempty(ARGS) ? ["general"] : ARGS
jet_only = length(args) == 1 && startswith(only(args), "jet")
if isempty(ARGS)
    @info "No test arguments provided; defaulting to `general` tests."
end
if jet_only
    @info "Routing to direct JET test execution." args project=TEST_PROJECTS["jet"]
    using Pkg
    Pkg.activate(TEST_PROJECTS["jet"])
    Pkg.instantiate()
else
    @info "Routing to ParallelTestRunner." args
end

test_project(name) = startswith(name, "jet") ? TEST_PROJECTS["jet"] : nothing

project_init_code(project::String) = quote
    using Pkg
    Pkg.activate($project)
end

testsuite = find_tests(@__DIR__)
filter!(testsuite) do (name, _)
    endswith(name, "_tests")
end

if !isempty(VERSION.prerelease) || get(ENV, "QUANTUMSAVORY_DOWNGRADE_TEST", "") == "true"
    delete!(testsuite, "general/aqua_tests")
end

function test_worker(name)
    project = test_project(name)
    project === nothing && return nothing
    return addworker(; init_worker_code = project_init_code(project))
end

if jet_only
    # Run JET directly rather than via ParallelTestRunner because
    # JET does not like being loaded after a Pkg.activate change.
    include(JET_TEST_PATH)
else
    using QuantumSymbolics
    runtests(QuantumSymbolics, args; testsuite, test_worker)
end
