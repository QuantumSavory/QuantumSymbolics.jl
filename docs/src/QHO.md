# Quantum Harmonic Oscillators

```@meta
DocTestSetup = quote
    using QuantumSymbolics, QuantumOptics
end
```

In this section, we describe symbolic representations of bosonic systems in QuantumSymbolics, which can be numerically translated to [`QuantumOptics.jl`](https://github.com/qojulia/QuantumOptics.jl).

## States

A Fock state is a state with well defined number of excitation quanta of a single quantum harmonic oscillator (an eigenstate of the number operator). In the following example, we create a [`FockState`](@ref) with 3 quanta in an infinite-dimension Fock space:

```jldoctest
julia> f = FockState(3)
|3⟩
```

Both vacuum (ground) and single-photon states are defined as constants in both unicode and ASCII for convenience:

- `vac = F₀ = F0` $=|0\rangle$ in the number state representation,
- `F₁ = F1` $=|1\rangle$ in the number state representation.

To create quantum analogues of a classical harmonic oscillator, or monochromatic electromagnetic waves, we can define a coherent (a.k.a. semi-classical) state $|\alpha\rangle$, where $\alpha$ is a complex amplitude, with [`CoherentState`](@ref):

```jldoctest
julia> c = CoherentState(im)
|im⟩
```
!!! note "Naming convention for quantum harmonic oscillator bases"
    The defined basis for arbitrary symbolic bosonic states is a `FockBasis` object, due to a shared naming interface for Quantum physics packages. For instance, the command `basis(CoherentState(im))` will output `Fock(cutoff=Inf)`. This may lead to confusion, as not all bosonic states are Fock states. However, this is simply a naming convention for the basis, and symbolic and numerical results are not affected by it.

Summarized below are supported bosonic states.

- Fock state: `FockState(idx::Int)`,
- Coherent state: `CoherentState(alpha::Number)`,
- Squeezed vacuum state: `SqueezedState(z::Number)`.
  
## Operators

Operations on bosonic states are supported, and can be simplified with [`qsimplify`](@ref) and its rewriter `qsimplify_fock`. For instance, we can apply the raising (creation) $\hat{a}^{\dagger}$ and lowering (annihilation or destroy) $\hat{a}$ operators on a Fock state as follows:

```jldoctest
julia> f = FockState(3);

julia> raise = Create*f
a†|3⟩

julia> qsimplify(raise, rewriter=qsimplify_fock)
(sqrt(4))|4⟩

julia> lower = Destroy*f
a|3⟩

julia> qsimplify(lower, rewriter=qsimplify_fock)
(sqrt(3))|2⟩
```
Or, we can apply the number operator $\hat{n}$ to our Fock state:

```jldoctest
julia> f = FockState(3);

julia> num = N*f
n|3⟩

julia> qsimplify(num, rewriter=qsimplify_fock)
3|3⟩
```

Constants are defined for number and ladder operators in unicode and ASCII:

- `N = n̂` $=\hat{n}$,
- `Create = âꜛ` $=\hat{a}^{\dagger}$,
- `Destroy = â` $=\hat{a}$.

Phase-shift $U(\theta)$ and displacement $D(\alpha)$ operators, defined respectively as

$$U(\theta) = \exp\left(-i\theta\hat{n}\right) \quad \text{and} \quad D(\alpha) = \exp\left(\alpha\hat{a}^{\dagger} - \alpha\hat{a}\right),$$ 

can be defined with usual simplification rules. Consider the following example:

```jldoctest
julia> displace = DisplaceOp(im)
D(im)

julia> c = qsimplify(displace*vac, rewriter=qsimplify_fock)
|im⟩

julia> phase = PhaseShiftOp(pi)
U(π)

julia> qsimplify(phase*c, rewriter=qsimplify_fock)
|1.2246467991473532e-16 - 1.0im⟩
```
Here, we generated a coherent state $|i\rangle$ from the vacuum state $|0\rangle$ by applying the displacement operator defined by [`DisplaceOp`](@ref). Then, we shifted its phase by $\pi$ with the phase shift operator (which is called with [`PhaseShiftOp`](@ref)) to get the result $|-i\rangle$.

Summarized below are supported bosonic operators.

- Number operator: `NumberOp()`,
- Creation operator: `CreateOp()`,
- Annihilation operator: `DestroyOp()`,
- Phase-shift operator: `PhaseShiftOp(phase::Number)`,
- Displacement operator: `DisplaceOp(alpha::Number)`,
- Squeezing operator: `SqueezeOp(z::Number)`.

## Numerical Conversions to QuantumOptics.jl

Bosonic systems can be translated to the ket representation with [`express`](@ref). For instance:

```jldoctest
julia> f = FockState(1);

julia> express(f)
Ket(dim=3)
  basis: Fock(cutoff=2)
 0.0 + 0.0im
 1.0 + 0.0im
 0.0 + 0.0im

julia> express(Create) |> dense
Operator(dim=3x3)
  basis: Fock(cutoff=2)
 0.0+0.0im      0.0+0.0im  0.0+0.0im
 1.0+0.0im      0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.41421+0.0im  0.0+0.0im

julia> express(Create*f)
Ket(dim=3)
  basis: Fock(cutoff=2)
                0.0 + 0.0im
                0.0 + 0.0im
 1.4142135623730951 + 0.0im

julia> express(Destroy*f)
Ket(dim=3)
  basis: Fock(cutoff=2)
 1.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
```

!!! warning "Cutoff specifications for numerical representations of quantum harmonic oscillators"
    Symbolic bosonic states and operators are naturally represented in an infinite dimension basis. For numerical conversions of such quantum objects, a finite cutoff of the highest allowed state must be defined. By default, the basis dimension of numerical conversions is set to 3 (so the number representation cutoff is 2), as demonstrated above. To define a different cutoff, one must customize the `QuantumOpticsRepr` instance, e.g. provide `QuantumOpticsRepr(cutoff=n::Int)` to [`express`](@ref).

If we wish to specify a different numerical cutoff, say 4, to the previous examples, then we rewrite them as follows:

```jldoctest
julia> f = FockState(1);

julia> express(f, QuantumOpticsRepr(cutoff=4))
Ket(dim=5)
  basis: Fock(cutoff=4)
 0.0 + 0.0im
 1.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im

julia> express(Create, QuantumOpticsRepr(4)) |> dense
Operator(dim=5x5)
  basis: Fock(cutoff=4)
 0.0+0.0im      0.0+0.0im      0.0+0.0im  0.0+0.0im  0.0+0.0im
 1.0+0.0im      0.0+0.0im      0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.41421+0.0im      0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im      0.0+0.0im  1.73205+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im      0.0+0.0im      0.0+0.0im  2.0+0.0im  0.0+0.0im
```