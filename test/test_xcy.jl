using Test
using QuantumSymbolics
using QuantumSymbolics: stab_to_ket
using QuantumClifford: @S_str, random_stabilizer, sXCY, CliffordOperator
using QuantumOptics
using QuantumSymbolics
using LinearAlgebra
#using QuantumOpticsExt: _l0, _l1, _s₊, _s₋, _i₊, _i₋
const qo = Base.get_extension(QuantumSymbolics, :QuantumOpticsExt)
const _l0 = qo._l0
const _l1 = qo._l1
const _s₊ = qo._s₊
const _s₋ = qo._s₋
const _i₊ = qo._i₊
const _i₋ = qo._i₋
const _xcy = qo._xcy
const _z = qo._z
const _hadamard = qo._hadamard
const _phase = qo._phase
const _cnot = qo._cnot
const _iphase = qo._iphase


for n in 1:5
    stabs = [random_stabilizer(1) for _ in 1:n]
    stab = tensor(stabs...)
    translate = Dict(S"X"=>_s₊,S"-X"=>_s₋,S"Z"=>_l0,S"-Z"=>_l1,S"Y"=>_i₊,S"-Y"=>_i₋)
    kets = [translate[s] for s in stabs]
    ket = tensor(kets...)
    @test ket.data ≈ stab_to_ket(stab).data

    rstab = random_stabilizer(2)
    lstab = random_stabilizer(2)
    lket = stab_to_ket(rstab)
    rket = stab_to_ket(lstab)

    rket_copy = copy(rket)


    dotket = abs(lket'*rket)
    dotstab = abs(dot(lstab,rstab))

    @test (dotket<=1e-10 && dotstab==0) || dotket≈dotstab
    


    xcy_andu = Operator(CliffordOperator(sXCY(1,2),2))

    apply!(rket, [1,2], xcy_andu)

    apply!(rket_copy, [1], _hadamard)
    apply!(rket_copy, [2], _iphase)
    apply!(rket_copy, [1,2], _cnot)
    apply!(rket_copy, [1], _hadamard)
    apply!(rket_copy, [2], _phase)

    @test rket == rket_copy
end

## There are some errors of precision ( 0 + 0.00i instead of 0 - 0.00i)
