##
# This file defines the expression of quantum objects (kets, operators, and bras) in various representations.
#
# The main function is `express`, which takes a quantum object and a representation and returns an expression of the object in that representation.
##

export express, express_nolookup, consistent_representation

import SymbolicUtils: Symbolic

"""
    express(s, repr::AbstractRepresentation=QuantumOpticsRepr()[, use::AbstractUse])

The main interface for expressing quantum objects in various representations.

```jldoctest
julia> express(X1)
Ket(dim=2)
  basis: Spin(1/2)
 0.7071067811865475 + 0.0im
 0.7071067811865475 + 0.0im

julia> express(X1, CliffordRepr())
𝒟ℯ𝓈𝓉𝒶𝒷
+ Z
𝒮𝓉𝒶𝒷
+ X

julia> express(QuantumSymbolics.X)
Operator(dim=2x2)
  basis: Spin(1/2)sparse([2, 1], [1, 2], ComplexF64[1.0 + 0.0im, 1.0 + 0.0im], 2, 2)

julia> express(QuantumSymbolics.X, CliffordRepr(), UseAsOperation())
sX

julia> express(QuantumSymbolics.X, CliffordRepr(), UseAsObservable())
+ X
```
"""
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
express(state::Symbolic) = express(state, QuantumOpticsRepr()) # The default representation
express_nolookup(state, ::QuantumMCRepr) = express_nolookup(state, QuantumOpticsRepr())

function express_nolookup(s, repr::AbstractRepresentation)
    if isexpr(s)
        operation(s)(express.(arguments(s), (repr,))...)
    else
        error("Encountered an object $(s) of type $(typeof(s)) that can not be converted to $(repr) representation") # TODO make a nice error type
    end
end