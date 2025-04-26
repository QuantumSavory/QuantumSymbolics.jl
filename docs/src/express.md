# Express functionality

```@meta
DocTestSetup = quote
    using QuantumSymbolics, QuantumOptics, QuantumClifford
end
```

A principle feature of `QuantumSymbolics` is to numerically represent symbolic quantum expressions in various formalisms using [`express`](@ref). In particular, one can translate symbolic logic to back-end toolboxes such as [`QuantumOptics.jl`](https://github.com/qojulia/QuantumOptics.jl) or [`QuantumClifford.jl`](https://github.com/QuantumSavory/QuantumClifford.jl) for simulating quantum systems with great flexibility.

As a straightforward example, consider the spin-up state $|\uparrow\rangle = |0\rangle$, the eigenstate of the Pauli operator $Z$, which can be expressed in `QuantumSymbolics` as follows:

```@example 1
using QuantumSymbolics, QuantumClifford, QuantumOptics # hide
ψ = Z1
```

Using [`express`](@ref), we can translate this symbolic object into its numerical state vector form in [`QuantumOptics.jl`](https://github.com/qojulia/QuantumOptics.jl).

```@example 1
express(ψ)
```

By default, [`express`](@ref) converts a quantum object with `QuantumOpticRepr`. It should be noted that [`express`](@ref) automatically caches this particular conversion of `ψ`. Thus, after running the above example, the numerical representation of the spin-up state is stored in the metadata of `ψ`.

```@example 1
ψ.metadata
```

The caching feature of [`express`](@ref) prevents a specific representation for a symbolic quantum object from being computed more than once. This becomes handy for translations of more complex operations, which can become computationally expensive. We also have the ability to express $|Z_1\rangle$ in the Clifford formalism with [`QuantumClifford.jl`](https://github.com/QuantumSavory/QuantumClifford.jl):

```@example 1
express(ψ, CliffordRepr())
```

Here, we specified an instance of `CliffordRepr` in the second argument to convert `ψ` into a tableau of Pauli operators containing its stabilizer and destabilizer states. Now, both the state vector and Clifford representation of `ψ` have been cached:

```@example 1
ψ.metadata
```

More involved examples can be explored. For instance, say we want to apply the tensor product $X\otimes Y$ of the Pauli operators $X$ and $Y$ to the Bell state $|\Phi^{+}\rangle = \dfrac{1}{\sqrt{2}}\left(|00\rangle + |11\rangle\right)$, and numerically express the result in the quantum optics formalism. This would be done as follows:

```@example 2
using QuantumSymbolics, QuantumClifford, QuantumOptics # hide
bellstate = (Z1⊗Z1+Z2⊗Z2)/√2
tp = σˣ⊗σʸ
express(tp*bellstate)
```

## Examples of Edge Cases
For Pauli operators, additional flexibility is given for translations to the Clifford formalism. Users have the option to convert a multi-qubit Pauli operator to an observable or operation with instances of `UseAsObservable` and `UseAsOperation`, respectively. Take the Pauli operator $Y$, for example, which in `QuantumSymbolics` is the constants `Y` or `σʸ`:

```jldoctest
julia> express(σʸ, CliffordRepr(), UseAsObservable())
+ Y

julia> express(σʸ, CliffordRepr(), UseAsOperation())
sY
```

Another edge case is translations with `QuantumOpticsRepr`, where we can additionally define a finite cutoff for bosonic states and operators, as discussed in the [quantum harmonic oscillators page](@ref Quantum-Harmonic-Oscillators). The default cutoff for such objects is 2, however a different cutoff can be specified by passing an integer to `QuantumOpticsRepr` in an `express` call. Let us see an example with the number operator:

```jldoctest
julia> express(N) |> dense
Operator(dim=3x3)
  basis: Fock(cutoff=2)
 0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  2.0+0.0im

julia> express(N, QuantumOpticsRepr(cutoff=4)) |> dense
Operator(dim=5x5)
  basis: Fock(cutoff=4)
 0.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  2.0+0.0im  0.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  3.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im  0.0+0.0im  0.0+0.0im  4.0+0.0im
```