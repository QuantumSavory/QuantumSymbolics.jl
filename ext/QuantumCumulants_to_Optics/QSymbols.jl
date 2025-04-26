function onesparams(H)
    params = get_numsymbols(H)
    rules = []
    for sym in params
        push!(rules,Pair(sym,1))
    end
    return Dict(rules)
end

function op_creator(op,space,idx,Ncutoff)
    aon = op.aon
    if space isa FockSpace
        if aon == idx
            if op isa Create
                return create(FockBasis(Ncutoff))
            elseif op isa Destroy
                return destroy(FockBasis(Ncutoff))
            else
                error("Unknown operator type $op")
            end
        else
            return one(FockBasis(Ncutoff))
        end
    elseif space isa NLevelSpace && length(space.levels) == 2
        if aon == idx
            if op isa Transition
                if op.j == space.GS && op.i != space.GS
                    return sigmap(SpinBasis(1//2))
                elseif op.i == space.GS && op.j != space.GS
                    return sigmam(SpinBasis(1//2))
                elseif op.i != space.GS && op.j != space.GS
                    return sigmaz(SpinBasis(1//2))
                else 
                    error("Don't know how to classify this transition $op")
                end
            else
                error("Unknown operator type $op")
            end
        else
            return one(SpinBasis(1//2))
        end
    else
        error("Unknown Hilbert space $space")
    end
end

function standard_initial_state(QOBasis)
    states = []
    for basis in QOBasis.bases
        if basis isa FockBasis
            push!(states, fockstate(basis,0))
        elseif basis isa SpinBasis && basis.spinnumber == 1//2
            push!(states,spindown(basis))
        end
    end
    return tensor(states...)
end


function convert_to_QO(exprlist,paramrules,Ncutoff)
    oldops = collect(get_qsymbols(sum(exprlist)))

    if check_hilberts(sum(oldops))
        hilb = first(oldops).hilbert
    else
        error("Expressions do not have homogenous Hilbert space")
    end

    subspaces = hilb.spaces

    newops = []
    for oldop in oldops
        newsubops = [op_creator(oldop,subspaces[idx],idx,Ncutoff) for idx in eachindex(subspaces)]
        newop = tensor(newsubops...)
        push!(newops,newop)
    end

    #now we need to substitute these operators into the symbolic expression of the Hamiltonian
    oprules = Dict([old => new for (old,new) in zip(oldops,newops)])
    num_expr = [substitute(X,paramrules) for X in exprlist]
    new_expr = [substitute(X,oprules) for X in num_expr]

    return new_expr
end

#Wrote this with chatgpt
function get_qsymbols(expr)
    if Symbolics.istree(expr)
        return union(get_qsymbols.(Symbolics.arguments(expr))...)
    else
        return (expr isa Number) || (expr isa SymbolicUtils.Symbolic) ? Set() : Set([expr])
    end
end

#modification of above function
function get_numsymbols(expr)
    if Symbolics.istree(expr)
        return union(get_numsymbols.(Symbolics.arguments(expr))...)
    else
        return (expr isa SymbolicUtils.Symbolic) ? Set([expr]) : Set() 
    end
end

function check_hilberts(expr)
    operators = get_qsymbols(expr)
    hilberts = [op.hilbert for op in operators]
    return all(y->y==hilberts[1],hilberts)
end