"""This file defines the expression of quantum objects (kets, operators, and bras) in various representations.

The main function is `express`, which takes a quantum object and a representation and returns an expression of the object in that representation."""

export express, express_nolookup, consistent_representation

import SymbolicUtils: Symbolic

function express(state::Symbolic, repr::AbstractRepresentation, use::AbstractUse)
    md = metadata(state)
    isnothing(md) && return express_from_cache(express_nolookup(state, repr, use))
    if haskey(md.express_cache,(repr,use))
        return express_from_cache(md.express_cache[(repr,use)])
    else
        cache = express_nolookup(state, repr, use)
        md.express_cache[(repr,use)] = cache
        return express_from_cache(cache)
    end
end

express(s::Number, repr::AbstractRepresentation, use::AbstractUse) = s

express(s, repr::AbstractRepresentation) = express(s, repr, UseAsState())

express_nolookup(x, repr::AbstractRepresentation, ::AbstractUse) = express_nolookup(x, repr)

express_nolookup(x, repr::AbstractRepresentation, ::UseAsState) = express_nolookup(x, repr)

# Most of the time the cache is exactly the expression we need,
# but we need indirection to be able to implement cases
# where the cache is a distribution over possible samples.
express_from_cache(cache) = cache

"""Pick a representation that is consistent with given representations and appropriate for the given state."""
function consistent_representation(reprs,state)
    reprs = Set(reprs)
    if length(reprs)>1
        error("There is no support for mixed representations in QuantumSymbolics.jl yet.")
    end
    first(reprs)
end

##
# Commonly used representations -- interfaces for each one defined in separate packages
##

"""Representation using kets, bras, density matrices, and superoperators governed by `QuantumOptics.jl`."""
struct QuantumOpticsRepr <: AbstractRepresentation end
"""Similar to `QuantumOpticsRepr`, but using trajectories instead of superoperators."""
struct QuantumMCRepr <: AbstractRepresentation end
"""Representation using tableaux governed by `QuantumClifford.jl`"""
struct CliffordRepr <: AbstractRepresentation end

express(state::Symbolic) = express(state, QuantumOpticsRepr()) # The default representation
express_nolookup(state, ::QuantumMCRepr) = express_nolookup(state, QuantumOpticsRepr())
express(state) = state

function express_nolookup(s, repr::AbstractRepresentation)
    if istree(s)
        operation(s)(express.(arguments(s), (repr,))...)
    else
        error("Encountered an object $(s) of type $(typeof(s)) that can not be converted to $(repr) representation") # TODO make a nice error type
    end
end
