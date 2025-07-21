# News

## v0.4.12 - dev

- Add Gabs extension for numerical translations of symbolic Gaussian states and operators.
- Add QuantumToolbox extension for state vector translations.

## v0.4.11 - 2025-06-22

- Bump compats for QuantumInterface and QuantumClifford.
- Add new symbolic bosonic states and operators (`TwoSqueezeOp`, `TwoSqueezedState`, `BosonicThermalState`, `BeamSplitterOp`).

## v0.4.10 - 2025-05-11

- Polish `Base.show` methods for application products and scaled quantum objects.
- Add test suite for `Base.show` methods of quantum symbolic types.

## v0.4.9 - 2025-04-23

- `Base.zero` implemented for quantum symbolic objects.

## v0.4.8 - 2025-02-25

- Proper expression of outer products in QuantumOptics.

## v0.4.7 - 2025-02-25

- Improvements to default flattening of expressions having nested sums and scalings.

## v0.4.6 - 2025-01-18

- Migrate `express` functionality and representation types to QuantumInterface.

## v0.4.5 - 2024-11-14

- Updated compat lower bounds for Symbolics to v6 (and for SymbolicUtils and TermInterface)

## v0.4.4 - 2024-09-16

- Implement squeezing with `SqueezeOp` and `SqueezedState`.

## v0.4.3 - 2024-08-13

- **(fix)** Fix for incorrect basis for `express(_,::QuantumOpticsRepr)` for certain operators.

## v0.4.2 - 2024-08-11

- `@withmetadata` now supports inline docstrings for struct fields

## v0.4.1 - 2024-08-11

- Minor documentation improvements.

## v0.4.0 - 2024-08-03

- Cleaned up metadata decoration of struct definitions.
- Added documentation for quantum harmonic oscillators.
- Added phase-shift and displacement operators `DisplaceOp` and `PhaseShiftOp`.
- Simplification rules for Fock objects.
- **(breaking)** `FockBasisState` was renamed to `FockState`.

## v0.3.4 - 2024-07-22

- Added `tr` and `ptrace` functionalities.
- New symbolic superoperator representations.
- Added linear algebra operations `exp`, `vec`, `conj`, `transpose`.
- Created a getting-started guide in docs.

## v0.3.3 - 2024-07-12

- Added single qubit simplification rules.
- Removed evaluation of metadata equality in `Base.isequal`.

## v0.3.2 - 2024-07-02

- Added documentation for `express`.
- `qsimplify` can now traverse through subexpressions using Prewalk from SymbolicUtils.jl.
- Updated `latexify` capabilities.
- **(fix)** There was a bug for latexifying dagger objects.
- Introduced `qexpand` function that manually expands expressions containing quantum objects.
- Organized automatic scaling and flattening procedures.

## v0.3.1 - 2024-06-21

- Macros for defining symbolic quantum objects.
- Implement zero objects.
- Equality for commutative operations, hashing, and lexicographic ordering when printing.
- Added tests.

## v0.3.0 - 2024-06-12

- Bump compat for symbolics-related foundational packages.
- Bump lowest julia requirement to 1.10.

## v0.2.7 - 2024-03-22

- Bump QuantumClifford compat.

## v0.2.6 - 2023-12-16

- Bumping compat bounds of multiple dependencies and checking minimal compats in CI.

## v0.2.5 - 2023-11-28

- Improvements to testing and documentation support.

## v0.2.4 - 2023-08-10

- Minor internal improvements to doc builder and interactions with QuantumSavory.jl.

## v0.2.3 - 2023-07-24

- Add all conditional Paulis.
- Remove `stab_to_ket` in favor of directly using the `Ket` constructor.

## v0.2.2 - 2023-06-28

- Bump `QuantumInterface` compat.
- Upstream some `apply!` definitions to QuantumOpticsBase.

## v0.2.1 - 2023-06-11

- Bump `QuantumInterface` compat.

## v0.2.0 - 2023-05-27

- **(breaking)** Merge with `QSymbolicsBase` and turn `QSymbolicsOptics` and `QSymbolicsClifford` into extensions.
- **(breaking)** Require julia 1.9.
- Drop `QuantumOptics` dependencies (now depends only on `QuantumOpticsBase`)

## `QSymbolicsBase` v0.1.2

- Pretty printing with Latexify.
- Implement bras.

## v0.1.1

- Bosonic states basis and common states and operators.
- Bumping `QSymbolicsBase` to 0.1.1.
- Bumping `QSymbolicsOptics` to 0.1.1.
- Added tests.

## `QSymbolicsBase` v0.1.1

- Bosonic states basis and common states and operators.
- Documentation and more symbol names available for the qubit base states.
- `SApplyOp` implemented for superoperator acting on operator.
- `STensorSuperOperator` implemented for tensor products of superoperators.
