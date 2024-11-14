using Latexify
using Latexify: LaTeXString

"""The label to put in between |⟩ or ⟨|, etc."""
function symbollabel end

"""Pretty printer helper for subscript indices"""
function num_to_sub(n::Int)
    str = string(n)
    replace(str,
        "1"=>"₁",
        "2"=>"₂",
        "3"=>"₃",
        "4"=>"₄",
        "5"=>"₅",
        "6"=>"₆",
        "7"=>"₇",
        "8"=>"₈",
        "9"=>"₉",
        "0"=>"₀",
    )
end
@latexrecipe function f(x::SBra)
    return Expr(:latexifymerge, "\\left\\langle ", symbollabel(x), "\\right|")
end
@latexrecipe function f(x::Union{SpecialKet,SKet})
    return Expr(:latexifymerge, "\\left|", symbollabel(x), "\\right\\rangle")
end
@latexrecipe function f(x::Union{SOperator,SHermitianOperator,SUnitaryOperator,SHermitianUnitaryOperator,AbstractSingleQubitOp,AbstractTwoQubitOp,AbstractSingleBosonOp})
    return LaTeXString("\\hat $(symbollabel(x))")
end
@latexrecipe function f(x::SZero)
    return LaTeXString("\\bm{O}")
end
@latexrecipe function f(x::SDagger)
    if isexpr(x.obj)
        return Expr(:latexifymerge, "\\left( ", latexify(x.obj), "\\right)^\\dagger")
    else
        return Expr(:latexifymerge, latexify(x.obj), "\\^\\dagger")
    end
end
@latexrecipe function f(x::Union{SScaled,SMulOperator,SOuterKetBra,SApplyKet,SApplyBra})
    cdot --> false
    return _toexpr(x)
end
@latexrecipe function f(x::SCommutator)
    return Expr(:latexifymerge, "\\left\\lbrack", latexify(x.op1), ",", latexify(x.op2), "\\right\\rbrack")
end
@latexrecipe function f(x::SAnticommutator)
    return Expr(:latexifymerge, "\\left\\{", latexify(x.op1), ",", latexify(x.op2), "\\right\\}")
end
@latexrecipe function f(x::SBraKet)
    return Expr(:latexifymerge, "\\left\\langle ", symbollabel(x.bra), "\\mid ", symbollabel(x.ket), "\\right\\rangle")
end
@latexrecipe function f(x::MixedState)
    return LaTeXString("\\mathbb{M}")
end

@latexrecipe function f(x::IdentityOp)
    return LaTeXString("\\mathbb{I}")
end
@latexrecipe function f(x::SInvOperator)
    return Expr(:latexifymerge, latexify(x.op), "\\^{-1}")
end

function _toexpr(x)
    if isexpr(x)
        return Expr(:call, head(x), arguments(x)...)
    else
        x
    end
end
function _addparen(x)
    if isexpr(x)
        return Expr(:latexifymerge, "\\left(", x, "\\right)")
    else
        return x
    end
end
function _toexpr(x::STensor)
    args = [b for a in arguments(x) for b in (_addparen(a), "\\otimes")][1:end-1]
    return Expr(:latexifymerge, args...)
end

@latexrecipe function f(x::SymQObj)
    return _toexpr(x)
end

Base.show(io::IO, ::MIME"text/latex", x::SymQObj) = print(io, latexify(x))
