@testitem "Aqua" tags=[:aqua] begin
    using Aqua
    
    # Add any new types needed to QObj, or here if QObj if not appropriate.
    # Add types from elsewhere in the ecosystem here or preferably to QObj
    own_types = [Base.uniontypes(QObj)...,AbstractRepresentation,AbstractUse,]
    own_types_union = Union{SymQObj,AbstractRepresentation,AbstractUse,}

    Aqua.test_all(QuantumSymbolics, piracies=(;treat_as_own=own_types))

    function normalize_arguments(method)
        args = Base.unwrap_unionall(method.sig).types[2:end]
        normalized_args = []
        # handle few edge cases specific to our analysis
        for arg in args
            # mutation and order of if-conditions is intedtional here
            if (arg isa UnionAll) && (arg.body <: Type) arg = arg.body.parameters[1] end
            if (arg isa Core.TypeofVararg) arg = arg.T end
            if (arg isa TypeVar) arg = arg.ub end
            push!(normalized_args, arg)
        end
        return normalized_args
    end

    # Custom type-piracy detection, to catch uses of QuantumInterface types without a Symbolic
    filtered_piracies = filter(Aqua.Piracy.hunt(QuantumSymbolics)) do m
        !any(normalize_arguments(m) .<: own_types_union)
    end

    aqua_piracies = Aqua.Piracy.hunt(QuantumSymbolics, treat_as_own=own_types)
    internally_detected_piracies = setdiff(filtered_piracies, aqua_piracies)
    if !isempty(internally_detected_piracies)
        printstyled(
            stderr,
            "Internally flagged possible type-piracy:\n";
            color = Base.warn_color()
        )
        show(stderr, MIME"text/plain"(), internally_detected_piracies)
        println(stderr, "\n")
    end
    @test isempty(internally_detected_piracies)
end
