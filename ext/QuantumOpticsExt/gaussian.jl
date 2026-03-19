using LinearAlgebra: diagm

finite_two_mode_basis(s, r) = isfinite(length(basis(s))) ? basis(s) : FockBasis(r.cutoff)^2

function _thermalstate(basis, photons)
    occupation = photons / (photons + 1)
    weights = occupation .^ collect(basis.offset:basis.N)
    normalize(DenseOperator(basis, diagm(0 => weights)))
end

function _two_mode_ops(basis)
    mode_basis = basis.bases[1]
    return (
        a1 = embed(basis, 1, destroy(mode_basis)),
        a2 = embed(basis, 2, destroy(mode_basis)),
        ad1 = embed(basis, 1, create(mode_basis)),
        ad2 = embed(basis, 2, create(mode_basis)),
    )
end

_phaseshift(basis, phase) = exp(-im * phase * dense(number(basis)))

function _beamsplitter(basis, transmit)
    ops = _two_mode_ops(basis)
    theta = asin(sqrt(transmit))
    exp(theta * dense(ops.ad1 * ops.a2 - ops.a1 * ops.ad2))
end

function _twosqueeze(basis, z)
    ops = _two_mode_ops(basis)
    exp(dense(conj(z) * ops.a1 * ops.a2 - z * ops.ad1 * ops.ad2))
end

function _two_mode_vacuum(basis)
    vacuum = fockstate(basis.bases[1], 0)
    vacuum ⊗ vacuum
end

express_nolookup(s::BosonicThermalState, r::QuantumOpticsRepr) = _thermalstate(finite_basis(s,r), s.photons)
express_nolookup(o::PhaseShiftOp, r::QuantumOpticsRepr) = _phaseshift(finite_basis(o,r), o.phase)
express_nolookup(o::BeamSplitterOp, r::QuantumOpticsRepr) = _beamsplitter(finite_two_mode_basis(o,r), o.transmit)
express_nolookup(s::TwoSqueezedState, r::QuantumOpticsRepr) = (b = finite_two_mode_basis(s,r); _twosqueeze(b, s.z) * _two_mode_vacuum(b))
express_nolookup(o::TwoSqueezeOp, r::QuantumOpticsRepr) = _twosqueeze(finite_two_mode_basis(o,r), o.z)
