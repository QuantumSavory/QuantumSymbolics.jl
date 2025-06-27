module GabsExt

using QuantumSymbolics
using QuantumSymbolics: CoherentState, GabsRepr
import QuantumSymbolics: express, express_nolookup

using Gabs

function express_nolookup(x::FockState, repr::GabsRepr)
    x.idx == 0 || throw(ArgumentError("Fock states with index ≥ 0 are non-Gaussian and unsupported via the Gabs representation."))
    return vacuumstate(repr.basis(1))
end
express_nolookup(x::CoherentState, repr::GabsRepr) = coherentstate(repr.basis(1), x.alpha)
express_nolookup(x::BosonicThermalState, repr::GabsRepr) = thermalstate(repr.basis(1), x.photons)
express_nolookup(x::PhaseShiftOp, repr::GabsRepr) = phaseshift(repr.basis(1), x.phase)
express_nolookup(x::DisplaceOp, repr::GabsRepr) = displace(repr.basis(1), x.alpha)
express_nolookup(x::BeamSplitterOp, repr::GabsRepr) = beamsplitter(repr.basis(2), x.transmit)

for (f,g) in [(:SqueezedState, :squeezedstate),(:SqueezeOp,:squeeze)]
    @eval function express_nolookup(x::$f, repr::GabsRepr)
        r, i = (real(x.z), imag(x.z))
        return ($g)(repr.basis(1), sqrt(r^2 + i^2), atan(i, r))
    end
end
for (f,g) in [(:TwoSqueezedState, :eprstate),(:TwoSqueezeOp,:twosqueeze)]
    @eval function express_nolookup(x::$f, repr::GabsRepr)
        r, i = (real(x.z), imag(x.z))
        return ($g)(repr.basis(2), sqrt(r^2 + i^2), atan(i, r))
    end
end

end