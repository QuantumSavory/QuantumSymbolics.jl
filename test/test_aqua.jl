using Aqua, QuantumSymbolics, QSymbolicsBase, QSymbolicsOptics, QSymbolicsClifford, Test

Aqua.test_all(QuantumSymbolics,ambiguities=false,piracy=false)
Aqua.test_all(QSymbolicsBase,ambiguities=false,piracy=false)
Aqua.test_all(QSymbolicsOptics,ambiguities=false,piracy=false)
Aqua.test_all(QSymbolicsClifford,ambiguities=false,piracy=false)
@test_broken false # test with ambiguities=true and maybe with piracy=true
