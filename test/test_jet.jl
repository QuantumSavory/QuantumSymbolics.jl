@testitem "JET checks" tags=[:jet] begin
using JET
using QuantumOptics, QuantumClifford # to load the extensions

using InteractiveUtils, Latexify, SymbolicUtils

rep = report_package("QuantumSymbolics";
    ignored_modules=(
        AnyFrameModule(InteractiveUtils),
        AnyFrameModule(Latexify),
        AnyFrameModule(SymbolicUtils)
    )
)
@show rep
@test_broken length(JET.get_reports(rep)) == 0
@test length(JET.get_reports(rep)) <= 6
end
