@testitem "Aqua" tags=[:aqua] begin
    using Aqua
    Aqua.test_all(QuantumSymbolics,
            ambiguities=(;broken=true),
            piracies=(;broken=true),
    )
end
