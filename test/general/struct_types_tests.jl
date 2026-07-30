using Test
using QuantumSymbolics
using QuantumSymbolics: @withmetadata, Metadata # `Metadata` is what the macro puts in the field

"""A decorated struct defined outside of any testset, so that its constructors can be inspected."""
@withmetadata struct FieldTypeTestStruct{T}
    a::T
end

##
# All the fields of all the structs of this library have to be (concretely) typed, either
# directly or through a type parameter, so that every instantiated symbolic object has a
# fixed memory layout and type-stable field access.
##

@testset "Concretely typed struct fields" begin
    import QuantumClifford # for StabilizerState (both packages export `X`, `Y` and `Z`)
    import QuantumOptics # to load the QuantumOptics and MixedCliffordOptics extensions
    using QuantumInterface: AbstractBra, AbstractOperator
    using QuantumSymbolics:
        inf_fock_basis, qubit_basis,
        MomentumEigenState, PositionEigenState, OperatorEmbedding, DepolarizationCPTP

    """All the struct types (excluding the callable objects) defined in a module."""
    function struct_types(m::Module)
        types = Set{Any}()
        for n in names(m; all=true)
            isdefined(m, n) || continue
            x = getproperty(m, n)
            x isa Type || continue
            T = Base.unwrap_unionall(x)
            T isa DataType || continue
            Base.isstructtype(T) || continue
            T <: Function && continue
            parentmodule(T) === m || continue # skip the imported and re-exported types
            push!(types, T.name.wrapper)
        end
        types
    end

    """Whether a declared field type is concrete for every concrete instantiation of its struct."""
    function isspecified(fieldtype)
        fieldtype isa TypeVar && return true # given by a type parameter
        fieldtype === Any && return false
        isconcretetype(fieldtype) && return true
        # e.g. `Dict{Symbolic{T},Any}` is concrete as soon as `T` is fixed
        fieldtype isa DataType && !isabstracttype(fieldtype) && return true
        false
    end

    underspecified(T) = [n=>t for (n,t) in zip(fieldnames(T), fieldtypes(T)) if !isspecified(t)]

    @testset "no underspecified field in any declaration" begin
        for m in (QuantumSymbolics,
                  Base.get_extension(QuantumSymbolics, :QuantumOpticsExt),
                  Base.get_extension(QuantumSymbolics, :QuantumCliffordExt),
                  Base.get_extension(QuantumSymbolics, :MixedCliffordOpticsExt))
            isnothing(m) && continue
            for T in struct_types(m)
                bad = underspecified(Base.unwrap_unionall(T))
                isempty(bad) || @error "underspecified fields" T bad
                @test isempty(bad)
            end
        end
    end

    # A representative object for every struct of the library. The coverage of this list is
    # checked below, so a newly added struct has to be given a representative here as well.
    @op A; @op B; @op C; @ket k; @bra b; @superop S₁; @superop S₂;
    @op 𝒪 qubit_basis⊗qubit_basis;
    corpus = Any[
        # literal objects and the zero objects
        k, b, A, S₁,
        SHermitianOperator(:ℋ), SUnitaryOperator(:U), SHermitianUnitaryOperator(:V),
        zero(k), zero(b), zero(A), zero(S₁),
        # homogeneous operations
        2*k, 2*b, 2*A, im*A, tr(A)*A,
        k+k*2, b+2*b, A+2*B,
        A*B,
        k⊗k, b⊗b, A⊗B, S₁⊗S₂,
        # inhomogeneous operations
        A*k, b*A, b*k, k*b,
        # superoperators
        kraus(A,B), S₁*A,
        # linear algebra
        commutator(A,B), anticommutator(A,B),
        conj(A), conj(k), transpose(A), transpose(k),
        dagger(A), dagger(k), dagger(b),
        projector(k), tr(A), ptrace(𝒪, 1), inv(A), exp(A), vec(A),
        # scalar expressions
        2*tr(A), tr(A)+tr(B), tr(A)*tr(B),
        # qubit states and gates
        X1, Y1, Z1, X, Y, Z, H, Pm, Pp, CNOT, CPHASE,
        XCX, XCY, XCZ, YCX, YCY, YCZ, ZCX, ZCY, ZCZ,
        # other predefined objects
        MixedState(k), IdentityOp(k), OperatorEmbedding(X, [1], qubit_basis⊗qubit_basis),
        MomentumEigenState(1.0, inf_fock_basis), PositionEigenState(1.0, inf_fock_basis),
        # harmonic oscillator states and operators
        FockState(1), CoherentState(im), SqueezedState(pi/4), TwoSqueezedState(pi/4),
        BosonicThermalState(2), N, Create, Destroy,
        PhaseShiftOp(pi), DisplaceOp(im), SqueezeOp(pi/4), TwoSqueezeOp(pi/4), BeamSplitterOp(0.5),
        # CPTP maps
        PauliNoiseCPTP(1/4,1/4,1/4), DephasingCPTP(1/4), DepolarizationCPTP(1/4, qubit_basis),
        AttenuatorCPTP(pi/4, 1), AmplifierCPTP(2.0, 1), GateCPTP(X, DephasingCPTP(1/4)),
        # backend dependent objects
        StabilizerState("XZ YY"),
        # bookkeeping objects
        Metadata(), QuantumToolboxRepr(),
    ]

    @testset "no underspecified field in any instantiation" begin
        for x in corpus
            T = typeof(x)
            bad = underspecified(T)
            isempty(bad) || @error "underspecified fields" T bad
            @test isconcretetype(T)
            @test isempty(bad)
            @test all(isconcretetype, fieldtypes(T))
        end
    end

    @testset "every struct has a representative above" begin
        covered = Set(Base.typename(typeof(x)).wrapper for x in corpus)
        missed = setdiff(struct_types(QuantumSymbolics), covered)
        isempty(missed) || @error "structs without a representative in the test corpus" missed
        @test isempty(missed)
    end

    @testset "type parameters are inferred from the arguments" begin
        @test SKet(:k) === SKet(:k, qubit_basis)
        @test typeof(SKet(:k)) == SKet{typeof(qubit_basis)}
        @test typeof(2*A) == SScaled{AbstractOperator,Int,typeof(A)}
        @test typeof(A*k) == SApplyKet{typeof(A),typeof(k)}
        @test typeof(dagger(k)) == SDagger{AbstractBra,typeof(k)}
        @test typeof(CoherentState(im)) == CoherentState{Complex{Bool}}
        @test typeof(DisplaceOp(1.0)) == DisplaceOp{Float64}
        @test 2*A isa SScaledOperator && 2*A isa SScaled{AbstractOperator}
        @test A+B isa SAddOperator && A⊗B isa STensorOperator
    end

    @testset "the type parameters do not change what is equal" begin
        @test isequal(CoherentState(1), CoherentState(1.0)) # as `isequal(1, 1.0)` is true
        @test isequal(2*A, 2.0*A)
        @test !isequal(CoherentState(1), CoherentState(2))
        @test !isequal(SKet(:k), SKet(:k, FockBasis(2))) # same struct, different basis
        @test !isequal(zero(k), zero(b)) # same struct, different kind of quantum object
        @test hash(zero(k)) != hash(zero(b))
        @test !isequal(A*B, A*B*C) # products of different lengths
        @test !isequal(A⊗B, A⊗B⊗C)
    end

    @testset "the generated constructor keeps the default ones suppressed" begin
        # The metadata is the last field, so Julia's default constructors would take it as their
        # last argument. Those must not exist: downstream packages add constructors of their own
        # to these structs, and a method of the same arity would silently overwrite a generated
        # one -- which is an error during precompilation (QuantumSavory does exactly this).
        @test typeof(FieldTypeTestStruct(1)) == FieldTypeTestStruct{Int}
        @test hasmethod(FieldTypeTestStruct, Tuple{Any})
        @test !hasmethod(FieldTypeTestStruct, Tuple{Any,Any})
        for T in (SProjector, SApplyKet, SScaled, MixedState, CoherentState, KrausRepr, SMulOperator)
            nargs = fieldcount(Base.unwrap_unionall(T)) # the fields, metadata included
            @test !hasmethod(T, Tuple{fill(Any, nargs)...})
        end
    end

    @testset "the metadata field is added last and stays out of the way" begin
        @test fieldnames(typeof(2*A))[end] == :metadata
        @test QuantumSymbolics.metadata(2*A) isa Metadata
        @test isnothing(QuantumSymbolics.metadata(A)) # literal objects are not cached
        @test isequal(2*A, 2*A) # the metadata is excluded from the comparisons
        @test hash(2*A) == hash(2*A)
    end
end
