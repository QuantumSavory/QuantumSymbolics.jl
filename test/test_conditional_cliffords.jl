@testitem "Conditional Cliffords" tags=[:clifford] begin
    using Pkg
    if get(Pkg.project().dependencies, "QuantumClifford", nothing) === nothing
        @test_skip "QuantumClifford not present in the test environment"
        return
    end
    try
        using QuantumClifford
    catch
        @test_skip "QuantumClifford not available in test environment"
        return
    end
    using QuantumOpticsBase
    using QuantumToolbox
    using LinearAlgebra

    P = [1. 0. 0. 0.;   # Maps QuantumOptics to QuantumToolbox basis
         0. 0. 1. 0.;
         0. 1. 0. 0.;
         0. 0. 0. 1.]
    for control in (:X, :Y, :Z)
        for target in (:X, :Y, :Z)
            structname = Symbol(control,"C",target,"Gate")
            gate = eval(structname)()
            gate_qo = express(gate, QuantumOpticsRepr())
            gate_qc = QuantumOpticsBase.Operator(CliffordOperator(express(gate, CliffordRepr(), UseAsOperation())(1,2),2))
            gate_qt = express(gate, QuantumToolboxRepr())
            @test gate_qo ≈ gate_qc
            @test P * gate_qo.data * P' ≈ gate_qt.data atol = 1e-10
        end
    end
end
