using Test
using QuantumSymbolics
using QuantumClifford
using QuantumOpticsBase
using LinearAlgebra

for control in (:X, :Y, :Z)
    for target in (:X, :Y, :Z)
        structname = Symbol(control,"C",target,"Gate")
        gate = eval(structname)()
        gate_qo = express(gate, QuantumOpticsRepr())
        gate_qc = Operator(CliffordOperator(express(gate, CliffordRepr(), UseAsOperation())(1,2),2))
        @test gate_qo ≈ gate_qc
    end
end
