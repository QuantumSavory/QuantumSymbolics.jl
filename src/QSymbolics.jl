module QSymbolics

using Reexport

@reexport using QSymBase

# Defines all the `express` methods for QuantumOptics
# in the `QuantumOpticsRepr` and `QuantumMCRepr`
using QSymOpt

# Defines all the `express` methods for QuantumClifford
# in the `CliffRepr`
using QSymCliff

include("should_upstream.jl")
include("mixed_objects.jl")

end
