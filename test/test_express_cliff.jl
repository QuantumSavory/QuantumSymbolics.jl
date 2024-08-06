@testitem "Clifford" begin
    using QuantumClifford
    using QuantumOptics

    state = StabilizerState(S"ZZ XX")
    state = SProjector(state)*0.5 + 0.5*MixedState(state)
    state2 = deepcopy(state)
    express(state, CliffordRepr())
    express(state, CliffordRepr())
    express(state2)
    express(state2)
    nocache = @timed express(state2, CliffordRepr())
    withcache = @timed express(state2, CliffordRepr())
    @test nocache.time > 2*withcache.time
    @test withcache.bytes <= 200
    results = Set([express(state2, CliffordRepr()) for i in 1:20])
    @test length(results)==2

    CR = CliffordRepr()
    UseOp = UseAsOperation()
    UseObs = UseAsObservable()

    @testset "Clifford representations for basis states" begin
        isequal(express(X1, CR), MixedDestabilizer(S"X"))
        isequal(express(X2, CR), MixedDestabilizer(S"-X"))
        isequal(express(Y1, CR), MixedDestabilizer(S"Y"))
        isequal(express(Y2, CR), MixedDestabilizer(S"-Y"))
        isequal(express(Z1, CR), MixedDestabilizer(S"Z"))
        isequal(express(Z2, CR), MixedDestabilizer(S"-Z"))
    end

    @testset "Clifford representations as observables" begin
        isequal(express(σˣ, CR, UseObs), P"X")
        isequal(express(σʸ, CR, UseObs), P"Y")
        isequal(express(σᶻ, CR, UseObs), P"Z")
        isequal(express(im*σˣ, CR, UseObs), im*P"X")
        isequal(express(σˣ⊗σʸ⊗σᶻ), P"X"⊗P"Y"⊗P"Z")
        isequal(express(σˣ*σʸ*σᶻ), P"X"*P"Y"*P"Z")
    end

    @testset "Clifford representations as operations" begin
        isequal(express(σˣ, CR, UseOp), sX)
        isequal(express(σʸ, CR, UseOp), sY)
        isequal(express(σᶻ, CR, UseOp), sZ)
    end
end
