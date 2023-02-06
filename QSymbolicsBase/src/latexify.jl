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

# TODO use Latexify for these
Base.show(io::IO, ::MIME"text/latex", x::SymQObj) = print(io, x)
