# Express functionality

```@meta
DocTestSetup = quote
    using QuantumSymbolics, QuantumOptics, QuantumClifford
end
```

A principle feature of `QuantumSymbolics` is to numerically represent symbolic quantum expressions in various formalisms using [`express`](@ref). In particular, one can translate symbolic logic to back-end toolboxes such as `QuantumOptics.jl` or `QuantumClifford.jl` for simulating quantum systems with great flexibiity.

As a straightforward example, consider the spin-up state $|\uparrow\rangle = |0\rangle$, the eigenstate of the Pauli operator $Z$, which can be expressed in `QuantumSymbolics` as follows:

```jldoctest
julia> ψ = Z1
|Z₁⟩
```
Using [`express`](@ref), we can translate this symbolic object into its numerical state vector form in `QuantumOptics.jl`.

```jldoctest
julia> ψ = Z1;

julia> express(ψ)
Ket(dim=2)
  basis: Spin(1/2)
 1.0 + 0.0im
 0.0 + 0.0im

julia> ψ.metadata
QuantumSymbolics.Metadata(Dict{Tuple{AbstractRepresentation, AbstractUse}, Any}((QuantumOpticsRepr(), UseAsState()) => Ket(dim=2)
  basis: Spin(1/2)
 1.0 + 0.0im
 0.0 + 0.0im))
```
By default, [`express`](@ref) converts a quantum object with [`QuantumOpticRepr`](@ref). It should be noted that [`express`](@ref) automatically caches this particular conversion of `ψ`. Thus, after running the above example, the numerical representation of the spin-up state is stored in the metadata of `ψ`.

The caching feature of [`express`](@ref) prevents a specific representation for a symbolic quantum object from being computed more than once. This becomes handy for translations of more complex operations, which can become computationally expensive. We also have the ability to express $|Z_1\rangle$ in the Clifford formalism with `QuantumClifford.jl`:
```jldoctest
julia> ψ = Z1;

julia> express(ψ, CliffordRepr())
𝒟ℯ𝓈𝓉𝒶𝒷
+ X
𝒮𝓉𝒶𝒷
+ Z

julia> ψ.metadata
QuantumSymbolics.Metadata(Dict{Tuple{AbstractRepresentation, AbstractUse}, Any}((CliffordRepr(), UseAsState()) => MixedDestablizer 1×1, (QuantumOpticsRepr(), UseAsState()) => Ket(dim=2)
  basis: Spin(1/2)
 1.0 + 0.0im
 0.0 + 0.0im))
```

Here, we specified an instance of [`CliffordRepr`](@ref) in the second argument to convert `ψ` into a tableau of Pauli operators containing its stabilizer and destabilizer states. Now, both the state vector and Clifford representation of `ψ` have been cached.

For Pauli operators, additional flexibility is given for translations to the Clifford formalism. Users have the option to convert a multi-qubit Pauli operator to an observable or operation with instances of [`UseAsObservable`](@ref) and [`UseAsOperation`](@ref), respectively. Take the Pauli operator $Y$, for example, which in `QuantumSymbolics` is the constants `Y` or `σʸ`:

```jldoctest
julia> express(σʸ, CliffordRepr(), UseAsObservable())
+ Y

julia> express(σʸ, CliffordRepr(), UseAsOperation())
sY
```
More involved examples can be explored. For instance, say we want to apply the tensor product $X\otimes Y$ of the Pauli operators $X$ and $Y$ to the Bell state $|\Phi^{+}\rangle = \dfrac{1}{\sqrt{2}}\left(|00\rangle + |11\rangle\right)$, and numerically express the result in the quantum optics formalism. This would be done as follows:

```jldoctest
julia> bellstate = (Z1⊗Z1+Z2⊗Z2)/√2
0.7071067811865475(|Z₁⟩|Z₁⟩+|Z₂⟩|Z₂⟩)

julia> tp = σˣ⊗σʸ
X⊗Y

julia> express(tp*bellstate)
Ket(dim=4)
  basis: [Spin(1/2) ⊗ Spin(1/2)]
 0.0 - 0.7071067811865475im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.7071067811865475im
```