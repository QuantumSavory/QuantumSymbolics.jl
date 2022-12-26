module QuantumSymbolics

using Reexport

@reexport using QSymbolicsBase

# Defines all the `express` methods for QuantumOptics
# in the `QuantumOpticsRepr` and `QuantumMCRepr`
using QSymbolicsOptics

# Defines all the `express` methods for QuantumClifford
# in the `CliffRepr`
using QSymbolicsClifford

include("should_upstream.jl")
include("mixed_objects.jl")

end
