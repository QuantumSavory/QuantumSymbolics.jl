using Aqua, QuantumSymbolics, Test

Aqua.test_all(QuantumSymbolics,
ambiguities=(;broken=true),
piracies=(;broken=true),
)
