using Test
using QuantumSymbolics
using QuantumCumulants
using QuantumOpticsBase
using QuantumCumulants: Destroy, Create # both packages export these; here the QuantumCumulants ones are meant
using QuantumSymbolics: QuantumCumulantsRepr, inf_fock_basis, qubit_basis

# `Destroy`, `Create`, `dagger`, `commutator`, ... are exported by both QuantumSymbolics and
# QuantumCumulants, so throughout this file the QuantumSymbolics ones are reached either
# through their unicode aliases (`â`, `âꜛ`, `n̂`) or through a qualified name.
const QS = QuantumSymbolics

@testset "QuantumCumulants" begin
    @testset "bosonic modes" begin
        h = FockSpace(:cavity)
        r = QuantumCumulantsRepr(h, [:a])
        a = Destroy(h, :a)
        @test isequal(express(â, r), a)
        @test isequal(express(âꜛ, r), a')
        @test isequal(express(n̂, r), a' * a)
        @test isequal(express(QS.dagger(â), r), a')
        @test isequal(express(2 * â, r), 2 * a)
        @test isequal(express(â + âꜛ, r), a + a')
        @test isequal(express(âꜛ * â, r), a' * a)
        @test isequal(express(QS.commutator(â, âꜛ), r), a * a' - a' * a)
        @test isequal(express(QS.anticommutator(â, âꜛ), r), a * a' + a' * a)
        @test isequal(express(SZeroOperator(), r), 0)
        @test isequal(express(IdentityOp(inf_fock_basis), r), 1)
    end

    @testset "two-level systems on an NLevelSpace" begin
        # `Z₁ = |0⟩` (the state `σ₊` raises to) is the excited level, `Z₂ = |1⟩` the ground one.
        h = NLevelSpace(:atom, (:g, :e))
        r = QuantumCumulantsRepr(h, [:σ])
        σ(i, j) = Transition(h, :σ, i, j)
        @test isequal(express(σ₋, r), σ(:g, :e))
        @test isequal(express(σ₊, r), σ(:e, :g))
        @test isequal(express(σᶻ, r), σ(:e, :e) - σ(:g, :g))
        @test isequal(express(σˣ, r), σ(:e, :g) + σ(:g, :e))
        @test isequal(express(σʸ, r), im * (σ(:g, :e) - σ(:e, :g)))
        @test isequal(express(projector(Z1), r), σ(:e, :e))
        @test isequal(express(projector(Z2), r), σ(:g, :g))
        @test isequal(express(Z1 * QS.dagger(Z2), r), σ(:e, :g))
        @test isequal(express(IdentityOp(qubit_basis), r), 1)

        # the level QuantumCumulants treats as the ground state is respected
        h2 = NLevelSpace(:atom, 2, 2) # two levels, the second of which is the ground state
        r2 = QuantumCumulantsRepr(h2, [:σ])
        @test isequal(express(σ₋, r2), Transition(h2, :σ, 2, 1))
        @test isequal(express(σᶻ, r2), Transition(h2, :σ, 1, 1) - Transition(h2, :σ, 2, 2))
    end

    @testset "multi-level systems" begin
        # beyond two levels the basis states are numbered the same way in both packages
        b = NLevelBasis(3)
        h = NLevelSpace(:atom, 3)
        r = QuantumCumulantsRepr(h, [:σ])
        @test isequal(express(projector(ZBasisState(2, b)), r), Transition(h, :σ, 2, 2))
        @test isequal(express(ZBasisState(1, b) * QS.dagger(ZBasisState(3, b)), r),
                      Transition(h, :σ, 1, 3))
        # the Hilbert space is derived from an NLevelBasis too
        @test isequal(express(projector(ZBasisState(2, b)), QuantumCumulantsRepr()),
                      Transition(NLevelSpace(:σ, 3), :σ, 2, 2))
    end

    @testset "two-level systems on a PauliSpace" begin
        h = PauliSpace(:spin)
        r = QuantumCumulantsRepr(h, [:σ])
        σx, σy, σz = Pauli(h, :σ, 1), Pauli(h, :σ, 2), Pauli(h, :σ, 3)
        @test isequal(express(σˣ, r), σx)
        @test isequal(express(σʸ, r), σy)
        @test isequal(express(σᶻ, r), σz)
        @test isequal(express(σ₊, r), (σx + im * σy) / 2)
        @test isequal(express(σ₋, r), (σx - im * σy) / 2)
        @test isequal(express(projector(Z1), r), (1 + σz) / 2)
        @test isequal(express(projector(Z2), r), (1 - σz) / 2)
    end

    @testset "tensor products place operators on the right subsystem" begin
        h = FockSpace(:cavity) ⊗ NLevelSpace(:atom, (:g, :e))
        r = QuantumCumulantsRepr(h, [:a, :σ])
        a = Destroy(h, :a)
        σ(i, j) = Transition(h, :σ, i, j, 2)
        @test isequal(express(â ⊗ IdentityOp(qubit_basis), r), a)
        @test isequal(express(IdentityOp(inf_fock_basis) ⊗ σ₋, r), σ(:g, :e))
        @test isequal(express(âꜛ ⊗ σ₋, r), a' * σ(:g, :e))
        @test isequal(express(n̂ ⊗ IdentityOp(qubit_basis), r), a' * a)

        # nested tensor products keep the same subsystem layout
        h3 = FockSpace(:c1) ⊗ FockSpace(:c2) ⊗ NLevelSpace(:atom, (:g, :e))
        r3 = QuantumCumulantsRepr(h3, [:a, :b, :σ])
        a1, a2 = Destroy(h3, :a, 1), Destroy(h3, :b, 2)
        @test isequal(express((â ⊗ âꜛ) ⊗ σ₊, r3), a1 * a2' * Transition(h3, :σ, :e, :g, 3))
    end

    @testset "the Hilbert space is derived from the basis when it is not given" begin
        @test isequal(express(â, QuantumCumulantsRepr()), Destroy(FockSpace(:a), :a))
        @test isequal(express(σ₋, QuantumCumulantsRepr()),
                      Transition(NLevelSpace(:σ, (:g, :e)), :σ, :g, :e))
        # subsystems of the same kind get numbered names, mixed ones do not
        hauto = FockSpace(:a) ⊗ NLevelSpace(:σ, (:g, :e))
        @test isequal(express(â ⊗ σ₋, QuantumCumulantsRepr()),
                      Destroy(hauto, :a, 1) * Transition(hauto, :σ, :g, :e, 2))
        h2f = FockSpace(:a1) ⊗ FockSpace(:a2)
        @test isequal(express(â ⊗ âꜛ, QuantumCumulantsRepr()),
                      Destroy(h2f, :a1, 1) * Destroy(h2f, :a2, 2)')
        # names can be given while still deriving the Hilbert space
        hn = FockSpace(:cavity) ⊗ NLevelSpace(:atom, (:g, :e))
        @test isequal(express(â ⊗ σ₋, QuantumCumulantsRepr(names=[:cavity, :atom])),
                      Destroy(hn, :cavity, 1) * Transition(hn, :atom, :g, :e, 2))
    end

    @testset "conversions agree with the QuantumOptics representation" begin
        cutoff = 4
        # a two-level space whose ground state is the second level matches the ordering of
        # `SpinBasis(1//2)`, so that the numerical matrices can be compared directly
        h = FockSpace(:cavity) ⊗ NLevelSpace(:atom, 2, 2)
        r = QuantumCumulantsRepr(h, [:a, :σ])
        exprs = [
            â ⊗ IdentityOp(qubit_basis),
            âꜛ ⊗ IdentityOp(qubit_basis),
            n̂ ⊗ IdentityOp(qubit_basis),
            IdentityOp(inf_fock_basis) ⊗ σ₋,
            IdentityOp(inf_fock_basis) ⊗ σ₊,
            IdentityOp(inf_fock_basis) ⊗ σˣ,
            IdentityOp(inf_fock_basis) ⊗ σʸ,
            IdentityOp(inf_fock_basis) ⊗ σᶻ,
            IdentityOp(inf_fock_basis) ⊗ projector(Z1),
            IdentityOp(inf_fock_basis) ⊗ (Z1 * QS.dagger(Z2)),
            âꜛ ⊗ σ₋ + â ⊗ σ₊,
            2 * (n̂ ⊗ σᶻ),
        ]
        for e in exprs
            qo = express(e, QuantumOpticsRepr(cutoff=cutoff))
            qc = to_numeric(express(e, r), h, [cutoff, 2]; backend=QuantumOpticsBackend())
            @test Matrix(dense(qo).data) ≈ Matrix(dense(qc).data)
        end

        # the same for the PauliSpace mapping of a bare qubit
        hp = PauliSpace(:spin)
        rp = QuantumCumulantsRepr(hp, [:σ])
        for e in [σˣ, σʸ, σᶻ, σ₊, σ₋, projector(Z1), projector(Z2), Z1 * QS.dagger(Z2)]
            qo = express(e, QuantumOpticsRepr())
            qc = to_numeric(express(e, rp), hp, 1 // 2; backend=QuantumOpticsBackend())
            @test Matrix(dense(qo).data) ≈ Matrix(dense(qc).data)
        end

        # QuantumCumulants works with the untruncated algebra, so commutators are evaluated
        # exactly rather than in a finite dimensional (truncated) representation
        hf = FockSpace(:cavity)
        rf = QuantumCumulantsRepr(hf, [:a])
        bf = FockBasis(cutoff)
        @test to_numeric(express(QS.commutator(â, âꜛ), rf), hf, cutoff; backend=QuantumOpticsBackend()) ≈
              identityoperator(bf)
        @test to_numeric(express(QS.anticommutator(â, âꜛ), rf), hf, cutoff; backend=QuantumOpticsBackend()) ≈
              identityoperator(bf) + 2 * number(bf)
    end

    @testset "symbolic scalars survive the conversion" begin
        @variables Δ::Real g::Real
        h = FockSpace(:cavity) ⊗ NLevelSpace(:atom, (:g, :e))
        r = QuantumCumulantsRepr(h, [:a, :σ])
        a = Destroy(h, :a)
        σ(i, j) = Transition(h, :σ, i, j, 2)
        H = express(Δ * (n̂ ⊗ IdentityOp(qubit_basis)) + g * (âꜛ ⊗ σ₋ + â ⊗ σ₊), r)
        @test isequal(H, Δ * a' * a + g * (a' * σ(:g, :e) + a * σ(:e, :g)))
    end

    @testset "the result can be fed to the QuantumCumulants machinery" begin
        @variables Δ::Real g::Real γ::Real κ::Real
        h = FockSpace(:cavity) ⊗ NLevelSpace(:atom, (:g, :e))
        r = QuantumCumulantsRepr(h, [:a, :σ])
        a = Destroy(h, :a)
        σ(i, j) = Transition(h, :σ, i, j, 2)

        # the Jaynes-Cummings Hamiltonian and its jump operators, written symbolically
        Hs = Δ * (n̂ ⊗ IdentityOp(qubit_basis)) + g * (âꜛ ⊗ σ₋ + â ⊗ σ₊)
        Js = [â ⊗ IdentityOp(qubit_basis), IdentityOp(inf_fock_basis) ⊗ σ₋]

        H = express(Hs, r)
        J = [express(j, r) for j in Js]
        eqs = complete(cumulant_expansion(meanfield([a' * a, σ(:e, :e)], H, J; rates=[κ, γ]), 2))
        @test eqs isa QuantumCumulants.AbstractMeanfieldEquations
        @test !isempty(eqs.equations)
    end

    @testset "unsupported objects throw" begin
        h = FockSpace(:cavity)
        r = QuantumCumulantsRepr(h, [:a])
        @test_throws ArgumentError express(Z1, QuantumCumulantsRepr())
        @test_throws ArgumentError express(QS.dagger(Z1), QuantumCumulantsRepr())
        @test_throws ArgumentError express(σ₋, r)                    # not a two-level space
        @test_throws ArgumentError express(â, QuantumCumulantsRepr(NLevelSpace(:a, 2), [:σ]))
        @test_throws ArgumentError express(â ⊗ â, r)                 # only one subsystem
        @test_throws ArgumentError express(σ₋, QuantumCumulantsRepr(NLevelSpace(:a, 3), [:σ]))
        # basis dependent operations have no counterpart in the QuantumCumulants algebra
        @test_throws ArgumentError express(conj(σˣ), QuantumCumulantsRepr(PauliSpace(:s), [:σ]))
        @test_throws ArgumentError express(transpose(σˣ), QuantumCumulantsRepr(PauliSpace(:s), [:σ]))
    end
end
