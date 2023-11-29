using Aqua, QuantumSymbolics, Test

Aqua.test_all(QuantumSymbolics, ambiguities=false, piracies=false, stale_deps=false)
@test_broken false # test with ambiguities=true, piracy, etc
