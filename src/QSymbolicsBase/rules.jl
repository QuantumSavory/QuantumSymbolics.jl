##
# This file defines automatic simplification rules for specific operations of quantum objects.
##

##
# Predicate functions
##
function hasscalings(xs)
    any(xs) do x
        operation(x) == *
    end
end
_isa(T) = x->isa(x,T)

##
# Determining factors for expressions containing quantum objects
##

function prefactorscalings(xs; scalar=false) # If the scalar keyword is true, then only scalar factors will be returned as coefficients
    terms = []
    coeff = 1::Any
    for x in xs
        if isexpr(x) && operation(x) == *
            c,t = arguments(x)
            if !scalar
                coeff *= c
                push!(terms,t)
            elseif scalar && c isa Number
                coeff *= c
                push!(terms, t)
            else
                push!(terms,(*)(arguments(x)...))
            end
        else
            push!(terms,x)
        end
    end
    coeff, terms
end

function prefactorscalings_rule(xs)
    coeff, terms = prefactorscalings(xs)
    coeff * ⊗(terms...)
end

function isnotflat_precheck(*)
    function (x)
        operation(x) === (*) || return false
        args = arguments(x)
        for t in args
            if isexpr(t) && operation(t) === (*)
                return true
            end
        end
        return false
    end
end

##
# Simplification rules
## 

# Flattening expressions
RULES_FLATTEN = [
    @rule(~x::isnotflat_precheck(⊗) => flatten_term(⊗, ~x)),
    @rule ⊗(~~xs::hasscalings) => prefactorscalings_rule(xs)
]

# Pauli identities
RULES_PAULI = [
    @rule(~o1::_isa(XGate)*~o2::_isa(XGate) => I),
    @rule(~o1::_isa(YGate)*~o2::_isa(YGate) => I),
    @rule(~o1::_isa(ZGate)*~o2::_isa(ZGate) => I),
    @rule(~o1::_isa(XGate)*~o2::_isa(YGate) => im*Z),
    @rule(~o1::_isa(YGate)*~o2::_isa(ZGate) => im*X),
    @rule(~o1::_isa(ZGate)*~o2::_isa(XGate) => im*Y),
    @rule(~o1::_isa(YGate)*~o2::_isa(XGate) => -im*Z),
    @rule(~o1::_isa(ZGate)*~o2::_isa(YGate) => -im*X),
    @rule(~o1::_isa(XGate)*~o2::_isa(ZGate) => -im*Y),
    @rule(~o1::_isa(HGate)*~o2::_isa(XGate)*~o3::_isa(HGate) => Z),
    @rule(~o1::_isa(HGate)*~o2::_isa(YGate)*~o3::_isa(HGate) => -Y),
    @rule(~o1::_isa(HGate)*~o2::_isa(ZGate)*~o3::_isa(HGate) => X)
]

# Commutator identities
RULES_COMMUTATOR = [
    @rule(commutator(~o1::_isa(XGate), ~o2::_isa(YGate)) => 2*im*Z),
    @rule(commutator(~o1::_isa(YGate), ~o2::_isa(ZGate)) => 2*im*X),
    @rule(commutator(~o1::_isa(ZGate), ~o2::_isa(XGate)) => 2*im*Y),
    @rule(commutator(~o1::_isa(YGate), ~o2::_isa(XGate)) => -2*im*Z),
    @rule(commutator(~o1::_isa(ZGate), ~o2::_isa(YGate)) => -2*im*X),
    @rule(commutator(~o1::_isa(XGate), ~o2::_isa(ZGate)) => -2*im*Y)
]

# Anticommutator identities
RULES_ANTICOMMUTATOR = [
    @rule(anticommutator(~o1::_isa(XGate), ~o2::_isa(XGate)) => 2*I),
    @rule(anticommutator(~o1::_isa(YGate), ~o2::_isa(YGate)) => 2*I),
    @rule(anticommutator(~o1::_isa(ZGate), ~o2::_isa(ZGate)) => 2*I),
    @rule(anticommutator(~o1::_isa(XGate), ~o2::_isa(YGate))=> 0),
    @rule(anticommutator(~o1::_isa(YGate), ~o2::_isa(ZGate)) => 0),
    @rule(anticommutator(~o1::_isa(ZGate), ~o2::_isa(XGate)) => 0),
    @rule(anticommutator(~o1::_isa(YGate), ~o2::_isa(XGate)) => 0),
    @rule(anticommutator(~o1::_isa(ZGate), ~o2::_isa(YGate)) => 0),
    @rule(anticommutator(~o1::_isa(XGate), ~o2::_isa(ZGate)) => 0)
]

RULES_ALL = [RULES_PAULI; RULES_COMMUTATOR; RULES_ANTICOMMUTATOR]

##
# Rewriters
##
qsimplify_flatten = Chain(RULES_FLATTEN)
qsimplify_anticommutator = Chain(RULES_ANTICOMMUTATOR)
qsimplify_pauli = Chain(RULES_PAULI)
qsimplify_commutator = Chain(RULES_COMMUTATOR)

"""Manually simplify a symbolic expression of quantum objects. 

If the keyword `rewriter` is not specified, then `qsimplify` will apply every defined rule to the expression. 
For performance or single-purpose motivations, the user has the option to define a specific rewriter for `qsimplify` to apply to the expression.

```jldoctest
julia> qsimplify(anticommutator(σˣ, σˣ), rewriter=qsimplify_anticommutator)
2𝕀
```
"""
function qsimplify(s; rewriter=nothing)
    if QuantumSymbolics.isexpr(s)
        if isnothing(rewriter)
            Fixpoint(Chain(RULES_ALL))(s)
        else
            Fixpoint(rewriter)(s)
        end
    else
        error("Object $(s) of type $(typeof(s)) is not an expression.")
    end
end

