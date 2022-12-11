using Aqua, QSymbolics, QSymbolicsBase, QSymbolicsOptics, QSymbolicsClifford, Test

Aqua.test_all(QSymbolics,ambiguities=false)
Aqua.test_all(QSymbolicsBase,ambiguities=false)
Aqua.test_all(QSymbolicsOptics,ambiguities=false)
Aqua.test_all(QSymbolicsClifford,ambiguities=false)
@test_broken false # test with ambiguities=true
