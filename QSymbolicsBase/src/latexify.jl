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

@latexrecipe function f(x::Union{SpecialKet,SKet})
    return Expr(:latexifymerge, "\\left|", symbollabel(x), "\\right\\rangle")
end
@latexrecipe function f(x::Union{SOperator,AbstractSingleQubitOp,AbstractTwoQubitOp,AbstractSingleBosonGate})
    return LaTeXString("\\hat $(symbollabel(x))")
end
@latexrecipe function f(x::SDagger)
    if istree(x.ket)
        return Expr(:latexifymerge, "\\left( ", x.ket, "\\right)^\\dagger")
    else
        return Expr(:latexifymerge, "\\left\\langle ", symbollabel(x), "\\right|")
    end
end
@latexrecipe function f(x::SScaled)
    cdot --> false
    return _toexpr(x)
end

function _toexpr(x)
    if istree(x)
        return Expr(:call, exprhead(x), arguments(x)...)
    else
        x
    end
end
function _addparen(x)
    if istree(x)
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
