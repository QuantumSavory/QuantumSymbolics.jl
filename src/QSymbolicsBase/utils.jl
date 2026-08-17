"""Pull the scalar prefactors out of the terms `xs`, returning the overall coefficient
together with the remaining unscaled objects (of the same element type as `xs`)."""
function prefactorscalings(xs::AbstractVector{E}) where {E}
    terms = E[]
    coeff::SymCoeff = 1
    for x in xs
        if isa(x, SScaled)
            coeff *= x.coeff
            push!(terms, x.obj)
        else
            push!(terms,x)
        end
    end
    coeff, terms
end

"""Flatten the nested applications of an associative operation, i.e. splice the arguments of
the terms that are themselves of type `C` (an `SMulOperator` or an `STensor`) into the result.

Only the terms of that very type are spliced: other expressions that happen to be products as
well (e.g. an `SOuterKetBra`, or the scalings taken care of by `prefactorscalings`) are kept
as single terms."""
function flattenop(::Type{C}, terms::AbstractVector{E}) where {C,E}
    newterms = E[]
    for obj in terms
        if isa(obj, C)
            append!(newterms, arguments(obj))
        else
            push!(newterms, obj)
        end
    end
    newterms
end

function countmap(samples) # A simpler version of StatsBase.countmap, because StatsBase is slow to import
    counts = Dict{Any,Any}()
    for s in samples
        counts[s] = get(counts, s, 0)+1
    end
    counts
end

"""Accumulate the coefficients of the repeated terms of a sum in a `Dict{K,SymCoeff}`, flattening
the nested sums (of type `ADD`) and pulling out the scalings (of type `MUL`) encountered."""
function countmap_flatten(samples, ::Type{ADD}, ::Type{MUL}, ::Type{K}) where {ADD,MUL,K}
    counts = Dict{K,SymCoeff}()
    for s in samples
        if s isa ADD
            for (term,coef) in pairs(s.dict)
                counts[term] = get(counts, term, 0)+coef
            end
        elseif s isa MUL
            coef, term = arguments(s)
            if term isa ADD
                for (_term,_coef) in pairs(term.dict)
                    counts[_term] = get(counts, _term, 0)+coef*_coef
                end
            else
                counts[term] = get(counts, term, 0)+coef
            end
        else
            counts[s] = get(counts, s, 0)+1
        end
    end
    for (term,coef) in pairs(counts)
        if iszero(coef)===true # iszero might return symbolic expressions instead of true/false # TODO make into a proper function like isdefinitelyzero, see whether upstream Symbolics has it
            delete!(counts, term)
        end
    end
    counts
end
