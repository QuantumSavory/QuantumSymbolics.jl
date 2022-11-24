using Aqua, QSymbolics, QSymBase, QSymOpt, QSymCliff, Test

Aqua.test_all(QSymbolics,ambiguities=false)
Aqua.test_all(QSymBase,ambiguities=false)
Aqua.test_all(QSymOpt,ambiguities=false)
Aqua.test_all(QSymCliff,ambiguities=false)
@test_broken false # test with ambiguities=true
