using Aqua, QuantumSymbolics, QSymbolicsBase, QSymbolicsOptics, QSymbolicsClifford, Test

Aqua.test_all(QuantumSymbolics,ambiguities=false)
Aqua.test_all(QSymbolicsBase,ambiguities=false)
Aqua.test_all(QSymbolicsOptics,ambiguities=false)
Aqua.test_all(QSymbolicsClifford,ambiguities=false)
@test_broken false # test with ambiguities=true
