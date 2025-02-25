function prefactorscalings(xs)
    terms = []
    coeff = 1::Any
    for x in xs
        if isa(x, SScaled)
            coeff *= x.coeff
            push!(terms, x.obj)
        elseif isa(x, Union{Number, Symbolic{Number}})
            coeff *= x
        else
            push!(terms,x)
        end
    end
    coeff, terms
end

function flattenop(f, terms)
    newterms = []
    for obj in terms
        if isexpr(obj) && operation(obj) === f
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

function countmap_flatten(samples, flattenadd, flattenmul)
    counts = Dict{Any,Any}()
    for s in samples
        if s isa flattenadd
            for (term,coef) in pairs(s.dict)
                counts[term] = get(counts, term, 0)+coef
            end
        elseif s isa flattenmul
            coef, term = arguments(s)
            if term isa flattenadd
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
