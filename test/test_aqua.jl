@testitem "Aqua" tags=[:aqua] begin
    using Aqua
    import QuantumInterface as QI
     own_types = [QI.AbstractBra, QI.AbstractKet, QI.AbstractSuperOperator, QI.AbstractOperator]
    Aqua.test_all(QuantumSymbolics,
            ambiguities=(),
            piracies=(;treat_as_own=own_types),
    )
end
