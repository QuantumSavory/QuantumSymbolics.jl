# This file contains types that depend on multiple backends
# or types for whom even the symbolic representation depends on a backend.

module MixedCliffordOpticsExt

using QuantumSymbolics
using QuantumInterface
using QuantumClifford, QuantumOpticsBase

using QuantumSymbolics: @withmetadata, Symbolic, AbstractKet, Metadata

using QuantumClifford: _T_str

import QuantumSymbolics: StabilizerState, express_nolookup

# using QuantumOpticsExt: _cphase, _z, _phase, _hadamard, _s₊
# or
#const qoe = Base.get_extension(QuantumSymbolics, :QuantumOpticsExt)
#const _cphase = qoe._cphase
#const _z = qoe._z
#const _phase = qoe._phase
#const _hadamard = qoe._hadamard
#const _s₊ = qoe._s₊
# or current solution
const _b2 = SpinBasis(1//2)
const _l0 = spinup(_b2)
const _l1 = spindown(_b2)
const _s₊ = (_l0+_l1)/√2
const _s₋ = (_l0-_l1)/√2
const _i₊ = (_l0+im*_l1)/√2
const _i₋ = (_l0-im*_l1)/√2
const _σ₊ = sigmap(_b2)
const _σ₋ = sigmam(_b2)
const _l00 = projector(_l0)
const _l11 = projector(_l1)
const _id = identityoperator(_b2)
const _z = sigmaz(_b2)
const _x = sigmax(_b2)
const _y = sigmay(_b2)
const _Id = identityoperator(_b2)
const _hadamard = (sigmaz(_b2)+sigmax(_b2))/√2
const _cnot = _l00⊗_Id + _l11⊗_x
const _cphase = _l00⊗_Id + _l11⊗_z
const _phase = _l00 + im*_l11
const _iphase = _l00 - im*_l11


function StabilizerState(x::Stabilizer)
    r,c = size(x)
    @assert r==c
    StabilizerState(MixedDestabilizer(x))
end
StabilizerState(x::String) = StabilizerState(Stabilizer(_T_str(x)))

express_nolookup(x::StabilizerState, ::CliffordRepr) = copy(x.stabilizer)

express_nolookup(x::StabilizerState, ::QuantumOpticsRepr) = Ket(stabilizerview(x.stabilizer))

end
