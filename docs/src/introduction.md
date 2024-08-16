# Getting Started with QuantumSymbolics.jl

```@meta
DocTestSetup = quote
    using QuantumSymbolics
end
```

QuantumSymbolics is designed for manipulation and numerical translation of symbolic quantum objects. This tutorial introduces basic features of the package.

## Installation

QuantumSymbolics.jl can be installed through the Julia package system in the standard way:

```
using Pkg
Pkg.add("QuantumSymbolics")
```

## Literal Symbolic Quantum Objects

Basic objects of type [`SBra`](@ref), [`SKet`](@ref), [`SOperator`](@ref), and [`SSuperOperator`](@ref) represent symbolic quantum objects with `name` and `basis` properties. Each type can be generated with a straightforward macro:

```jldoctest
julia> using QuantumSymbolics

julia> @bra b # object of type SBra
⟨b|

julia> @ket k # object of type SKet
|k⟩

julia> @op A # object of type SOperator
A

julia> @superop S # object of type SSuperOperator
S
```

By default, each of the above macros defines a symbolic quantum object in the spin-1/2 basis. One can simply choose a different basis, such as the Fock basis or a tensor product of several bases, by passing an object of type `Basis` to the second argument in the macro call:

```jldoctest
julia> @op B FockBasis(Inf, 0.0)
B

julia> basis(B)
Fock(cutoff=Inf)

julia> @op C SpinBasis(1//2)⊗SpinBasis(5//2)
C

julia> basis(C)
[Spin(1/2) ⊗ Spin(5/2)]
```
Here, we extracted the basis of the defined symbolic operators using the `basis` function.

Symbolic quantum objects with additional properties can be defined, such as a Hermitian operator, or the zero ket (i.e., a symbolic ket equivalent to the zero vector $\bm{0}$).

## Basic Operations

Expressions containing symbolic quantum objects can be built with a variety of functions. Let us consider the most fundamental operations: multiplication `*`, addition `+`, and the tensor product `⊗`. 

We can multiply, for example, a ket by a scalar value, or apply an operator to a ket:

```jldoctest
julia> @ket k; @op A;

julia> 2*k
2|k⟩

julia> A*k
A|k⟩
```

Similar scaling procedures can be performed on bras and operators. Addition between symbolic objects is also available, for instance:

```jldoctest
julia> @op A₁; @op A₂;

julia> A₁+A₂
(A₁+A₂)

julia> @bra b;

julia> 2*b + 5*b
7⟨b|
```
Built into the package are straightforward automatic simplification rules, as shown in the last example, where `2⟨b|+5⟨b|` evaluates to `7⟨b|`. 

Tensor products of symbolic objects can be performed, with basis information transferred:

```jldoctest
julia> @ket k₁; @ket k₂;

julia> tp = k₁⊗k₂
|k₁⟩|k₂⟩

julia> basis(tp)
[Spin(1/2) ⊗ Spin(1/2)]
```

Inner and outer products of bras and kets can be generated:

```jldoctest
julia> @bra b; @ket k;

julia> b*k
⟨b||k⟩

julia> k*b
|k⟩⟨b|
```

More involved combinations of operations can be explored. Here are few other straightforward examples:

```jldoctest
julia> @bra b; @ket k; @op A; @op B;

julia> 3*A*B*k
3AB|k⟩

julia> A⊗(k*b + B)
(A⊗(B+|k⟩⟨b|))

julia> A-A
𝟎
```
In the last example, a zero operator, denoted `𝟎`, was returned by subtracting a symbolic operator from itself. Such an object is of the type [`SZeroOperator`](@ref), and similar objects [`SZeroBra`](@ref) and [`SZeroKet`](@ref) correspond to zero bras and zero kets, respectively.

## Linear Algebra on Bras, Kets, and Operators

QuantumSymbolics supports a wide variety of linear algebra on symbolic bras, kets, and operators. For instance, the commutator and anticommutator of two operators, can be generated:

```jldoctest
julia> @op A; @op B;

julia> commutator(A, B)
[A,B]

julia> anticommutator(A, B)
{A,B}

julia> commutator(A, A)
𝟎
```
Or, one can take the dagger of a quantum object with the [`dagger`](@ref) function:

```jldoctest
julia> @ket k; @op A; @op B;

julia> dagger(A)
A†

julia> dagger(A*k)
|k⟩†A†

julia> dagger(A*B)
B†A†
```
Below, we state all of the supported linear algebra operations on quantum objects:

- commutator of two operators: [`commutator`](@ref),
- anticommutator of two operators: [`anticommutator`](@ref),
- complex conjugate: [`conj`](@ref),
- transpose: [`transpose`](@ref),
- projection of a ket: [`projector`](@ref),
- adjoint or dagger: [`dagger`](@ref),
- trace: [`tr`](@ref),
- partial trace: [`ptrace`](@ref),
- inverse of an operator: [`inv`](@ref),
- exponential of an operator: [`exp`](@ref),
- vectorization of an operator: [`vec`](@ref).

## Predefined Quantum Objects

So far in this tutorial, we have considered arbitrary kets, bras, operators, and their corresponding operations. This package supports predefined quantum objects and operations in several formalisms, which are discussed in detail in other sections (see, for example, the [quantum harmonic oscillators](@ref Quantum-Harmonic-Oscillators) or [qubit basis](@ref Typical-Qubit-Bases) pages). To get a taste of what's available, let us consider a few symbolic examples. For a complete description, see the [full API page](@ref Full-API).

Quantum gates and their basis states can be represented symbolically:

```jldoctest
julia> CNOT # CNOT Gate
CNOT

julia> X, Y, Z, I # Pauli operators
(X, Y, Z, 𝕀)

julia> X1, X2 # Eigenstates of the Pauli X operator
(|X₁⟩, |X₂⟩)

julia> H * (Z1 ⊗ Z2) # Application of Hadamard gate on |01⟩
H|Z₁⟩|Z₂⟩
```

We also have symbolic representations of bosonic systems:

```jldoctest
julia> FockState(4) # Fock state with 4 quantum harmonic oscillators
|4⟩

julia> Create, Destroy # creation and annihilation operators
(a†, a)

julia> DisplaceOp(im) # Displacement operator for single bosonic mode
D(im)

julia> N * vac # Application of number operator on vacuum state
n|0⟩
```

If we want to substitute a predefined quantum object into a general symbolic expression, we can use the [`substitute`](https://symbolics.juliasymbolics.org/v3.5/manual/expression_manipulation/#SymbolicUtils.substitute) command from [`Symbolics.jl`](https://github.com/JuliaSymbolics/Symbolics.jl):

```jldoctest
julia> using Symbolics

julia> @op A; @ket k;

julia> ex = 2*A + projector(k)
(2A+𝐏[|k⟩])

julia> substitute(ex, Dict([A => X, k => X1]))
(2X+𝐏[|X₁⟩])
```

## Simplifying Expressions

For predefined objects such as the Pauli operators [`X`](@ref), [`Y`](@ref), and [`Z`](@ref), additional simplification can be performed with the [`qsimplify`](@ref) function. Take the following example:

```jldoctest
julia> qsimplify(X*Z)
(0 - 1im)Y
```

Here, we have the relation $XZ = -iY$, so calling [`qsimplify`](@ref) on the expression `X*Z` will rewrite the expression as `-im*Y`.

Note that simplification rewriters used in QuantumSymbolics are built from the interface of [`SymbolicUtils.jl`](https://github.com/JuliaSymbolics/SymbolicUtils.jl). By default, when called on an expression, [`qsimplify`](@ref) will iterate through every defined simplification rule in the QuantumSymbolics package until the expression can no longer be simplified. 

Now, suppose we only want to use a specific subset of rules. For instance, say we wish to simplify commutators, but not anticommutators. Then, we can pass the keyword argument `rewriter=qsimplify_commutator` to [`qsimplify`](@ref), as done in the following example:

```jldoctest
julia> qsimplify(commutator(X, Y), rewriter=qsimplify_commutator)
(0 + 2im)Z

julia> qsimplify(anticommutator(X, Y), rewriter=qsimplify_commutator)
{X,Y}
```
As shown above, we apply [`qsimplify`](@ref) to two expressions: `commutator(X, Y)` and `anticommutator(X, Y)`. We specify that only commutator rules will be applied, thus the first expression is rewritten to `(0 + 2im)Z` while the second expression is simply returned. This feature can greatly reduce the time it takes for an expression to be simplified.

Below, we state all of the simplification rule subsets that can be passed to [`qsimplify`](@ref):

- `qsimplify_pauli` for Pauli multiplication,
- `qsimplify_commutator` for commutators of Pauli operators,
- `qsimplify_anticommutator` for anticommutators of Pauli operators.

## Expanding Expressions

Symbolic expressions containing quantum objects can be expanded with the [`qexpand`](@ref) function. We demonstrate this capability with the following examples.

```jldoctest
julia> @op A; @op B; @op C;

julia> qexpand(A⊗(B+C))
((A⊗B)+(A⊗C))

julia> qexpand((B+C)*A)
(BA+CA)

julia> @ket k₁; @ket k₂; @ket k₃;

julia> qexpand(k₁⊗(k₂+k₃))
(|k₁⟩|k₂⟩+|k₁⟩|k₃⟩)

julia> qexpand((A*B)*(k₁+k₂))
(AB|k₁⟩+AB|k₂⟩)
```

## Numerical Translation of Symbolic Objects

Symbolic expressions containing predefined objects can be converted to numerical representations with [`express`](@ref). Numerics packages supported by this translation capability are [`QuantumOptics.jl`](https://github.com/qojulia/QuantumOptics.jl) and [`QuantumClifford.jl`](https://github.com/QuantumSavory/QuantumClifford.jl/).

By default, [`express`](@ref) converts an object to the quantum optics state vector representation. For instance, we can represent the exponential of the Pauli operator [`X`](@ref) numerically as follows:

```jldoctest
julia> using QuantumOptics

julia> express(exp(X))
Operator(dim=2x2)
  basis: Spin(1/2)sparse([1, 2, 1, 2], [1, 1, 2, 2], ComplexF64[1.5430806327160496 + 0.0im, 1.1752011684303352 + 0.0im, 1.1752011684303352 + 0.0im, 1.5430806327160496 + 0.0im], 2, 2)
```

To convert to the Clifford representation, an instance of `CliffordRepr` must be passed to [`express`](@ref). For instance, we can represent the projection of the basis state [`X1`](@ref) of the Pauli operator [`X`](@ref) as follows:

```jldoctest
julia> using QuantumClifford

julia> express(projector(X1), CliffordRepr())
𝒟ℯ𝓈𝓉𝒶𝒷
+ Z
𝒮𝓉𝒶𝒷
+ X
```
For more details on using [`express`](@ref), refer to the [express functionality page](@ref express).