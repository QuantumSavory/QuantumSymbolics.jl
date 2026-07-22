using Test
using QuantumSymbolics
using Gabs
using QuantumClifford
using QuantumOptics
using QuantumToolbox

function own_struct_types(mod)
    types = []
    for name in names(mod; all=true, imported=false)
        occursin("#", string(name)) && continue
        isdefined(mod, name) || continue
        T = getfield(mod, name)
        (T isa DataType || T isa UnionAll) || continue
        T_unwrapped = Base.unwrap_unionall(T)
        Base.typename(T_unwrapped).module === mod || continue
        fields = try
            fieldnames(T_unwrapped)
        catch
            continue
        end
        isempty(fields) && continue
        push!(types, T)
    end
    types
end

@testset "struct field types" begin
    modules = [
        QuantumSymbolics,
        Base.get_extension(QuantumSymbolics, :GabsExt),
        Base.get_extension(QuantumSymbolics, :QuantumCliffordExt),
        Base.get_extension(QuantumSymbolics, :QuantumOpticsExt),
        Base.get_extension(QuantumSymbolics, :QuantumToolboxExt),
        Base.get_extension(QuantumSymbolics, :MixedCliffordOpticsExt),
    ]

    for mod in modules
        @test mod !== nothing
        any_fields = []
        for T in own_struct_types(mod)
            T_unwrapped = Base.unwrap_unionall(T)
            for name in fieldnames(T_unwrapped)
                name === :metadata && continue
                if fieldtype(T_unwrapped, name) === Any
                    push!(any_fields, (mod, T, name))
                end
            end
        end
        @test isempty(any_fields)
    end
end
