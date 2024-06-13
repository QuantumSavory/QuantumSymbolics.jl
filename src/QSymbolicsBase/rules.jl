"""This file defines automatic simplification rules for specific operations of quantum objects"""

"""Predicate functions"""
function hasscalings(xs)
    any(xs) do x
        operation(x) == *
    end
end
_isH(x) = x isa HGate
_isX(x) = x isa XGate
_isY(x) = x isa YGate
_isZ(x) = x isa ZGate

"""Flattening terms"""
function prefactorscalings(xs)
    terms = []
    coeff = 1::Any
    for x in xs
        if istree(x) && operation(x) == *
            c,t = arguments(x)
            coeff *= c
            push!(terms,t)
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
            if istree(t) && operation(t) === (*)
                return true
            end
        end
        return false
    end
end

FLATTEN_RULES = [
    @rule(~x::isnotflat_precheck(⊗) => flatten_term(⊗, ~x)),
    @rule ⊗(~~xs::hasscalings) => prefactorscalings_rule(xs) # Used to perform (a*|k⟩) ⊗ (b*|l⟩) → (a*b) * (|k⟩⊗|l⟩) 
]

tensor_simplify = Fixpoint(Chain(FLATTEN_RULES))

"""Quantum circuit identities"""
_isXX(x) = x isa SApplyOp && x.terms == [X,X] # work on this with identity op
_isYY(x) = x isa SApplyOp && x.terms == [Y,Y]
_isZZ(x) = x isa SApplyOp && x.terms == [Z,Z]
_isXY(x) = x isa SApplyOp && x.terms == [X,Y]
_isYZ(x) = x isa SApplyOp && x.terms == [Y,Z]
_isZX(x) = x isa SApplyOp && x.terms == [Z,X]
_isYX(x) = x isa SApplyOp && x.terms == [Y,X]
_isZY(x) = x isa SApplyOp && x.terms == [Z,Y]
_isXZ(x) = x isa SApplyOp && x.terms == [X,Z]
_isHXH(x) = x isa SApplyOp && x.terms == [H,X,H]
_isHYH(x) = x isa SApplyOp && x.terms == [H,Y,H]
_isHZH(x) = x isa SApplyOp && x.terms == [H,Z,H]


CIRCUIT_RULES = [
    @rule(~x::_isXY => im*Z),
    @rule(~x::_isYZ => im*X),
    @rule(~x::_isZX => im*Y),
    @rule(~x::_isYX => -im*Z),
    @rule(~x::_isZY => -im*X),
    @rule(~x::_isXZ => -im*Y),
    @rule(~x::_isHXH => Z),
    @rule(~x::_isHYH => -Y),
    @rule(~x::_isHZH => X)
]

circuit_simplify = Fixpoint(Chain(CIRCUIT_RULES))

"""Commutator identities"""
_isXYcommutator(x) = x isa SCommutator && _isX(x.op1) && _isY(x.op2)
_isYZcommutator(x) = x isa SCommutator && _isY(x.op1) && _isZ(x.op2)
_isZXcommutator(x) = x isa SCommutator && _isZ(x.op1) && _isX(x.op2)

COMMUTATOR_RULES = [
    @rule(~x::_isXYcommutator => 2*im*Z),
    @rule(~x::_isYZcommutator => 2*im*X),
    @rule(~x::_isZXcommutator => 2*im*Y)
]

commutator_simplify = Fixpoint(Chain(COMMUTATOR_RULES))

"""Anticommutator identities"""
_isXYanticommutator(x) = x isa SAnticommutator && _isX(x.op1) && _isY(x.op2)
_isYZanticommutator(x) = x isa SAnticommutator && _isY(x.op1) && _isZ(x.op2)
_isZXanticommutator(x) = x isa SAnticommutator && _isZ(x.op1) && _isX(x.op2)

ANTICOMMUTATOR_RULES = [
    @rule(~x::_isXYanticommutator => 0),
    @rule(~x::_isYZanticommutator => 0),
    @rule(~x::_isZXanticommutator => 0)
]

anticommutator_simplify = Fixpoint(Chain(ANTICOMMUTATOR_RULES))