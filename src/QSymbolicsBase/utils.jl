
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

function countmap_flatten(samples, flattenhead)
    counts = Dict{Any,Any}()
    for s in samples
        if isexpr(s) && s isa flattenhead # TODO Could you use the TermInterface `operation` here instead of `flattenhead`?
            coef, term = arguments(s)
            counts[term] = get(counts, term, 0)+coef
        else
            counts[s] = get(counts, s, 0)+1
        end
    end
    counts
end
