##
# Lazy operator support for QuantumOpticsRepr
#
# When `lazy=true`, symbolic sums, products, and tensor products of operators
# are expressed using QuantumOpticsBase lazy operator types:
# LazySum, LazyProduct, and LazyTensor respectively.
# This preserves symbolic structure and avoids early matrix materialization.
##

using QuantumOpticsBase:
    LazySum, LazyProduct, LazyTensor, CompositeBasis, basis,
    ⊗, tensor, AbstractOperator

import QuantumSymbolics:
    SAddOperator, SMulOperator, STensorOperator,
    SScaledOperator, SZeroOperator, SScaled,
    basis, arguments, express

import TermInterface: isexpr

# For SZeroOperator: return empty LazySum with default basis
function _express_zero_term(r::QuantumOpticsRepr)
    b = SpinBasis(1//2)
    return LazySum(b, b, ComplexF64[], ())
end

# SAddOperator: symbolic sum → LazySum when lazy=true
function express_nolookup(x::SAddOperator, r::QuantumOpticsRepr)
    if r.lazy
        args = arguments(x)
        if isempty(args)
            return _express_zero_term(r)
        end
        # Express each argument
        expressed = [express(a, r) for a in args]
        # LazySum handles mixed types via its arithmetic operators
        return +(expressed...)
    else
        return +(express.(arguments(x), Ref(r))...)
    end
end

# SMulOperator: symbolic product → LazyProduct when lazy=true
function express_nolookup(x::SMulOperator, r::QuantumOpticsRepr)
    if r.lazy
        args = arguments(x)
        if isempty(args)
            return _express_zero_term(r)
        end
        expressed = [express(a, r) for a in args]
        return LazyProduct(Tuple(expressed))
    else
        return *(express.(arguments(x), Ref(r))...)
    end
end

# STensorOperator: symbolic tensor product → LazyTensor when lazy=true
function express_nolookup(x::STensorOperator, r::QuantumOpticsRepr)
    if r.lazy
        args = arguments(x)
        if isempty(args)
            return _express_zero_term(r)
        end
        expressed = [express(a, r) for a in args]

        n = length(expressed)
        indices = collect(1:n)
        b_l = CompositeBasis(basis.(expressed))
        b_r = CompositeBasis(basis.(expressed))

        return LazyTensor(b_l, b_r, indices, Tuple(expressed))
    else
        return ⊗(express.(arguments(x), Ref(r))...)
    end
end

# SScaledOperator: coefficient * operator (leaf-level)
# When the inner is a LazySum, multiply the coefficients.
# Otherwise multiply the operator directly.
function express_nolookup(x::SScaledOperator, r::QuantumOpticsRepr)
    inner = express(x.obj, r)
    if r.lazy && inner isa LazySum
        # Multiply each coefficient in the LazySum
        new_factors = x.coeff .* inner.factors
        return LazySum(inner.basis_l, inner.basis_r, new_factors, inner.operators)
    else
        return x.coeff * inner
    end
end

# Commutator: [A, B] = A*B - B*A
function express_nolookup(x::SCommutator, r::QuantumOpticsRepr)
    if r.lazy
        e_op1 = express(x.op1, r)
        e_op2 = express(x.op2, r)
        prod1 = LazyProduct((e_op1, e_op2))
        prod2 = LazyProduct((e_op2, e_op1))
        return LazySum(prod1) - LazySum(prod2)
    else
        e_op1 = express(x.op1, r)
        e_op2 = express(x.op2, r)
        return e_op1 * e_op2 - e_op2 * e_op1
    end
end

# Anticommutator: {A, B} = A*B + B*A
function express_nolookup(x::SAnticommutator, r::QuantumOpticsRepr)
    if r.lazy
        e_op1 = express(x.op1, r)
        e_op2 = express(x.op2, r)
        prod1 = LazyProduct((e_op1, e_op2))
        prod2 = LazyProduct((e_op2, e_op1))
        return LazySum(prod1) + LazySum(prod2)
    else
        e_op1 = express(x.op1, r)
        e_op2 = express(x.op2, r)
        return e_op1 * e_op2 + e_op2 * e_op1
    end
end
