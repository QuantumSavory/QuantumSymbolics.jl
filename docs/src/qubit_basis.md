# Typical Qubit Bases

```@meta
DocTestSetup = quote
    using QuantumSymbolics, QuantumOptics
end
```

Here are some common conventions for representing a qubit in a physical system. This reference is provided as the conventions matter to the correct choice of noise processes and bases in which they are represented.

In monospaced `code` format we give the symbols by which these objects are callable in `QuantumSymbolics`. We provide unicode and ASCII names for convenience of typing.

## Spin $\frac{1}{2}$ qubits

First we introduce the Pauli matrices:

```jldoctest
julia> express(σᶻ) |> dense # or `Z`
Operator(dim=2x2)
  basis: Spin(1/2)
 1.0+0.0im   0.0+0.0im
 0.0+0.0im  -1.0+0.0im

julia> express(σˣ) |> dense # or `X`
Operator(dim=2x2)
  basis: Spin(1/2)
 0.0+0.0im  1.0+0.0im
 1.0+0.0im  0.0+0.0im

julia> express(σʸ) |> dense # or `Y`
Operator(dim=2x2)
  basis: Spin(1/2)
 0.0+0.0im  -0.0-1.0im
 0.0+1.0im   0.0+0.0im
```

Above `dense` is from `QuantumOptics`, used to convert their representation to a dense matrix.

The eigenvectors of each one of them provides for a convenient basis. The σᶻ basis is also called the *computational basis*. As mentioned, we have both unicode and ASCII names for convenience of typing. For these basis vectors we also have two sets of names: one based on which operator they are eigenvectors of and one in terms of typical logical representation (with prefix `L`).

- `Z1 = Z₁ = L0 = L₀ = ` $|0\rangle = \begin{pmatrix}1\\0\end{pmatrix} = |\uparrow\rangle$ with eigenvalue +1 for σᶻ
- `Z2 = Z₂ = L1 = L₁ = ` $|1\rangle = \begin{pmatrix}0\\1\end{pmatrix} = |\downarrow\rangle$ with eigenvalue +1 for σᶻ
- `X1 = X₁ = Lp = L₊ = ` $|+\rangle = \frac{1}{\sqrt 2}\begin{pmatrix}1\\1\end{pmatrix}$ with eigenvalue +1 for σˣ
- `X2 = X₂ = Lm = L₋ = ` $|-\rangle = \frac{1}{\sqrt 2}\begin{pmatrix}1\\-1\end{pmatrix}$ with eigenvalue -1 for σˣ
- `Y1 = Y₁ = Lpi = L₊ᵢ = ` $|+i\rangle = \frac{1}{\sqrt 2}\begin{pmatrix}1\\ i\end{pmatrix}$ with eigenvalue +1 for σʸ
- `Y2 = Y₂ = Lmi = L₋ᵢ = ` $|-i\rangle = \frac{1}{\sqrt 2}\begin{pmatrix}1\\-i\end{pmatrix}$ with eigenvalue -1 for σʸ

The Y vectors occasionally are denoted with R and L (stemming from the vector notation for right and left polarized light), but there is no established notation choice or ordering.

!!! warning "Talking about ground/excited and spin-up/spin-down states can lead to confusion"
    We specifically avoid using notation with "ground" and "excited" states. For physicist usually the excited state is the "up" states ($|e\rangle=|\uparrow\rangle$), but that historical choice clashes with the logical state notation as we have the logical **zero** be the "excited" state. This clash becomes particularly confusing when noise processes and relaxation process are taken into account. E.g. one might think the operator usually denoted $\hat{\sigma}_-$ would be the one corresponding to decay but we actually have $\hat{\sigma}_-|0\rangle=|1\rangle$. To avoid this confusion we strive to **not use** the notation $|\uparrow\rangle$, $|\downarrow\rangle$, $|e\rangle$, and $|g\rangle$. Similarly we strongly prefer to never use $\hat{\sigma}_-$ and $\hat{\sigma}_+$, rather only use $|1\rangle \langle0|$ and its conjugate.
    If we were instead talking about single-rail photonic qubits, we do not have the same issue (because the diagonal of the number operator is growing, instead of decreasing like the diagonal of the Pauli Z).


The basis states can be easily expressed both as kets and as tableaux (In the tableau representation below the top half corresponds to the destabilizer, while the bottom is the stabilizer):

```jldoctest
julia> express(L0, CliffordRepr())
Rank 1 stabilizer
+ X
═══
+ Z
═══


julia> express(L1, CliffordRepr())
Rank 1 stabilizer
+ X
═══
- Z
═══


julia> express(L₀, CliffordRepr())
Rank 1 stabilizer
+ X
═══
+ Z
═══


julia> express(L₁, CliffordRepr())
Rank 1 stabilizer
+ X
═══
- Z
═══


julia> express(L₊, CliffordRepr())
Rank 1 stabilizer
+ Z
═══
+ X
═══


julia> express(L₋, CliffordRepr())
Rank 1 stabilizer
+ Z
═══
- X
═══


julia> express(L₊ᵢ, CliffordRepr())
Rank 1 stabilizer
+ Z
═══
+ Y
═══


julia> express(L₋ᵢ, CliffordRepr())
Rank 1 stabilizer
+ Z
═══
- Y
═══
```

```jldoctest
julia> express(L₀)
Ket(dim=2)
  basis: Spin(1/2)
 1.0 + 0.0im
 0.0 + 0.0im

julia> express(L₁)
Ket(dim=2)
  basis: Spin(1/2)
 0.0 + 0.0im
 1.0 + 0.0im

julia> express(L₊)
Ket(dim=2)
  basis: Spin(1/2)
 0.7071067811865475 + 0.0im
 0.7071067811865475 + 0.0im

julia> express(L₋)
Ket(dim=2)
  basis: Spin(1/2)
  0.7071067811865475 + 0.0im
 -0.7071067811865475 + 0.0im

julia> express(L₊ᵢ)
Ket(dim=2)
  basis: Spin(1/2)
 0.7071067811865475 + 0.0im
                0.0 + 0.7071067811865475im

julia> express(L₋ᵢ)
Ket(dim=2)
  basis: Spin(1/2)
 0.7071067811865475 + 0.0im
                0.0 - 0.7071067811865475im
```