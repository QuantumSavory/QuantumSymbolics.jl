# Fock States

```@meta
DocTestSetup = quote
    using QuantumSymbolics, QuantumOptics
end
```

In this section, we describe symbolic representations of Fock states in QuantumSymbolics, which can be numerically translated to `QuantumOptics.jl`. A Fock state is the number state representation $|n\rangle$ of a system with $n$ particles. 

One can define a basis of the Fock space with `FockBasis(N, offset=0)`, where `N` is the highest available Fock state and `offset` is the lowest cutoff state, which is by default zero. In the following example, we create a `FockState` with 3 quanta in an infinite-dimension Fock space:

```jldoctest
julia> b = FockBasis(Inf, 0.0)
Fock(cutoff=Inf)

julia> f = FockState(3, b)
|3⟩
```

Both vacuum (ground) and single-photon states in an infinite-dimension Fock basis are defined as constants in both unicode and ASCII for convenience:

- `vac = F₀ = F0` $=|0\rangle$ in the number state representation,
- `F₁ = F1` $=|1\rangle$ in the number state representation.

To create quantum analogues of a classical harmonic oscillator, or monochromatic electromagnetic waves, we can define a coherent state $|\alpha\rangle$, where $\alpha$ is a complex amplitude, with `ContinuousCoherentState(α::Number, basis::Basis)`:

```jldoctest
julia> b = FockBasis(Inf, 0.0);

julia> c = ContinuousCoherentState(im, b)
|0 + im⟩
```

## Operators

Operations on fock states are supported, and can be simplified with `qsimplify` and its rewriter `qsimplify_fock`. For instance, we can apply the raising (creation) $a^{\dagger}$ and lowering (annihilation or destroy) $a$ operators on a fock state as follows:

```jldoctest
julia> b = FockBasis(Inf, 0.0);

julia> f = FockState(3, b);

julia> raise = Create*f
a†|3⟩

julia> qsimplify(raise, rewriter=qsimplify_fock)
2.0|4⟩

julia> lower = Destroy*f
a|3⟩

julia> qsimplify(lower, rewriter=qsimplify_fock)
1.7320508075688772|2⟩
```
Or, we can apply the number operator $\hat{n}$ to our fock state:

```jldoctest
julia> b = FockBasis(Inf, 0.0);

julia> f = FockState(3, b);

julia> num = N*f
n|3⟩

julia> qsimplify(num, rewirter=qsimplify_fock)
3|3⟩
```

In the infinite dimension case for Fock states, constants are defined for number and ladder operators:

- `N = n̂` $=\hat{n}$,
- `Create = âꜛ` $=\hat{a}^{\dagger}$,
- `Destroy = â` $=\hat{a}$.

Phase-shift $U(\theta)$ and displacement $D(\alpha)$ operators, defined respectively as 
$$U(\theta) = \exp\left(-i\theta\hat{n}\right) \quad \text{and} \quad D(\alpha) = \exp\left(\alpha\hat{a}^{\dagger} - \alpha\hat{a}\right),$$
can be defined. Consider the following example:

```jldoctest
julia> b = FockBasis(Inf, 0.0);

julia> displace = DisplacementOp(im, b)
D(im)

julia> c = qsimplify(displace*v, rewriter=qsimplify_fock)
|im⟩

julia> phase = PhaseShiftOp(pi, b)
U(π)

julia> qsimplify(phase*c, rewriter=qsimplify_fock)
|1.2246467991473532e-16 - 1.0im⟩
```
Here, we generated a coherent state $|i\rangle$ from the vacuum state $|0\rangle$ by applying the displacement operator defined by `DisplacementOp`. Then, we shifted its phase by $\pi$ with the phase shift operator (which is called with `PhaseShiftOp`) to get the result $|-i\rangle$.

Summarized below are supported operators, which can be defined in any Fock basis.

- Number operator: `NumberOp(basis:Basis)`,
- Creation operator: `CreateOp(basis::Basis)`,
- Annihilation operator: `DestroyOp(basis::Basis)`,
- Phase-shift operator: `PhaseShiftOp(phase::Number, basis:Basis)`,
- Displacement operator: `DisplacementOp(alpha::Number, basis::Basis)`.

## Numerical Conversions to QuantumOptics.jl

Fock systems can be translated to the ket representation with `express`. For instance:

```jldoctest
julia> using QuantumOptics

julia> b = FockBasis(3);

julia> f = FockState(1, b);

julia> express(f)
Ket(dim=4)
  basis: Fock(cutoff=3)
 0.0 + 0.0im
 1.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im

julia> julia> express(CreateOp(b)) |> dense
Operator(dim=4x4)
  basis: Fock(cutoff=3)
 0.0+0.0im      0.0+0.0im      0.0+0.0im  0.0+0.0im
 1.0+0.0im      0.0+0.0im      0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.41421+0.0im      0.0+0.0im  0.0+0.0im
 0.0+0.0im      0.0+0.0im  1.73205+0.0im  0.0+0.0im

julia> express(CreateOp(b)*f)
Ket(dim=4)
  basis: Fock(cutoff=3)
                0.0 + 0.0im
                0.0 + 0.0im
 1.4142135623730951 + 0.0im
                0.0 + 0.0im

julia> express(DestroyOp(b)*f)
Ket(dim=4)
  basis: Fock(cutoff=3)
 1.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
```