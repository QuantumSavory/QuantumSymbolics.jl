# Mean-field equations with QuantumCumulants.jl

[`QuantumCumulants.jl`](https://github.com/qojulia/QuantumCumulants.jl) derives and solves
*symbolic* equations of motion for expectation values of quantum operators, truncated at a
chosen order of the cumulant expansion. `QuantumSymbolics` can convert its symbolic
operators into the second-quantized operators `QuantumCumulants` works with, so a model
written once in `QuantumSymbolics` can be handed to the cumulant machinery without being
rewritten by hand.

The conversion is done with [`express`](@ref) and an instance of `QuantumCumulantsRepr`.
Unlike the other representations, the result is not a numerical matrix: it is another
symbolic object, living in the operator algebra of `QuantumCumulants`.

!!! note "Name clashes"
    Both packages export `Destroy`, `Create`, `dagger`, `commutator` and `anticommutator`.
    When both are loaded, those names have to be qualified (`QuantumSymbolics.Destroy`,
    `QuantumCumulants.Destroy`, ...), or reached through the `QuantumSymbolics` unicode
    aliases `â`, `âꜛ` and `n̂`, which is what is done below.

## A first example

`QuantumCumulants` operators always live on a Hilbert space that says how many subsystems
there are and of what kind. Pass that space, together with the name each operator should
carry, to `QuantumCumulantsRepr`:

```@example qc
using QuantumSymbolics
using QuantumCumulants
using QuantumCumulants: Destroy, Transition  # both packages export `Destroy`

h = FockSpace(:cavity) ⊗ NLevelSpace(:atom, (:g, :e))
repr = QuantumCumulantsRepr(h, [:a, :σ])

express(â ⊗ QuantumSymbolics.σ₋, repr)
```

The `i`-th factor of a tensor product is placed on the `i`-th subsystem of the Hilbert
space, and identity factors are used to say that a subsystem is not acted on:

```@example qc
Iₐ = IdentityOp(SpinBasis(1//2))
Ic = IdentityOp(FockBasis(Inf, 0.0))

express(â ⊗ Iₐ, repr)
```

## The Jaynes-Cummings model

With that in place, a full model can be written symbolically and then converted:

```@example qc
@variables Δ::Real g::Real κ::Real γ::Real

Hsym = Δ*(n̂ ⊗ Iₐ) + g*(âꜛ ⊗ QuantumSymbolics.σ₋ + â ⊗ QuantumSymbolics.σ₊)
```

```@example qc
H = express(Hsym, repr)
```

```@example qc
J = [express(â ⊗ Iₐ, repr), express(Ic ⊗ QuantumSymbolics.σ₋, repr)]
```

The results are ordinary `QuantumCumulants` objects, so the rest of the workflow is the
usual one:

```@example qc
a = Destroy(h, :a)
σ(i, j) = Transition(h, :σ, i, j, 2)

eqs = meanfield([a'*a, σ(:e, :e)], H, J; rates=[κ, γ])
eqs = complete(cumulant_expansion(eqs, 2))
```

## Conventions

`QuantumSymbolics` labels the qubit basis states as ``|0\rangle = Z_1`` (spin up, the state
``\sigma_+`` raises to) and ``|1\rangle = Z_2`` (spin down). When a two-level system is
mapped onto an `NLevelSpace`, ``Z_1`` is identified with its *excited* level and ``Z_2``
with its *ground* level (the one recorded in the `ground_state` field of the
`NLevelSpace`). With the customary `NLevelSpace(:atom, (:g,:e))` this gives the familiar
identifications

| `QuantumSymbolics` | `QuantumCumulants` |
|:--|:--|
| `σ₋` | ``\sigma^{ge} = \|g\rangle\langle e\|`` |
| `σ₊` | ``\sigma^{eg}`` |
| `σᶻ` | ``\sigma^{ee} - \sigma^{gg}`` |
| `σˣ` | ``\sigma^{eg} + \sigma^{ge}`` |
| `σʸ` | ``i(\sigma^{ge} - \sigma^{eg})`` |
| `projector(Z1)` | ``\sigma^{ee}`` |
| `Z1*dagger(Z2)` | ``\sigma^{eg}`` |
| `â`, `âꜛ`, `n̂` | ``a``, ``a^\dagger``, ``a^\dagger a`` |
| `IdentityOp(b)` | ``1`` |

Two-level systems can also be put on a `PauliSpace`, in which case they are converted to
`Pauli` operators instead:

```@example qc
express(QuantumSymbolics.σ₊, QuantumCumulantsRepr(PauliSpace(:spin), [:σ]))
```

## Letting the Hilbert space be derived

If no Hilbert space is given, one is built from the basis of the expression being
converted: a `FockBasis` becomes a `FockSpace`, a two-level `SpinBasis` becomes a
two-level `NLevelSpace`, an `NLevelBasis` becomes an `NLevelSpace`, and a `CompositeBasis`
becomes a `ProductSpace`. The subsystems are named automatically, or after the `names`
keyword argument:

```@example qc
express(â ⊗ QuantumSymbolics.σ₋, QuantumCumulantsRepr())
```

```@example qc
express(â ⊗ QuantumSymbolics.σ₋, QuantumCumulantsRepr(names=[:cavity, :atom]))
```

This is convenient for quick conversions, but for anything beyond that it is better to
build the Hilbert space explicitly: only then are the names of the resulting operators
under your control, and only operators with matching names and Hilbert spaces are
recognized as the same operator by `QuantumCumulants`.
