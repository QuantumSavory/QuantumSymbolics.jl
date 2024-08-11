@testitem "Test metadata decoration" begin
    using QuantumSymbolics: Metadata, @withmetadata
    
    @withmetadata struct Foo1
        a::Int
    end
    @test Foo1(2).metadata isa Metadata

    @withmetadata struct Foo2
        "hi"
        a::Int
    end
    @test Foo2(2).metadata isa Metadata

    @withmetadata struct Foo3{T<:Int}
        "hi"
        a::T
        "hi"
        b::T
    end
    @test Foo3{Int}(2, 3).metadata isa Metadata

    @withmetadata struct Foo4{T<:Int} <: Integer
        a::T
        b::T
    end
    @test Foo4{Int}(2, 3).metadata isa Metadata

    @withmetadata struct Foo5 <: Integer
        a
    end
    @test Foo5(2).metadata isa Metadata

    @withmetadata struct Foo6 <: Integer end
    @test Foo6().metadata isa Metadata
end