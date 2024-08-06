@testitem "Express opt" begin
    import QuantumClifford
    import QuantumOptics

    state = 1im*X2⊗Z1+2*Y1⊗(Z2+X2)+StabilizerState("XZ YY")
    express(state)
    express(state)
    state = 1im*X1⊗Z2+2*Y2⊗(Z1+X1)+StabilizerState("YX ZZ")
    nocache = @timed express(state)
    withcache = @timed express(state)
    @test nocache.time > 10*withcache.time
    @test withcache.bytes == 0
    @test nocache.value ≈ withcache.value ≈ express(1im*X1⊗Z2+2*Y2⊗(Z1+X1)+StabilizerState("YX ZZ"))

    state = 1im*X1⊗Z2+2*Y2⊗(Z1+X1)+StabilizerState("YX ZZ")
    state = SProjector(state)+2*X⊗(Z+Y)/3im
    state = state+MixedState(state)
    state2 = deepcopy(state)
    express(state)
    express(state)
    nocache = @timed express(state2)
    withcache = @timed express(state2)
    @test nocache.time > 50*withcache.time
    @test withcache.bytes == 0
    @test nocache.value ≈ withcache.value ≈ express(state2)

    state = 1im*F1⊗F0
    state1 = N⊗Create * state
    @test express(state1) ≈ 1im*express(F1)⊗express(F1)
    @test express(IdentityOp(F1)⊗Destroy)*express(state1) ≈ express((IdentityOp(F1)⊗Destroy)*state1) ≈ express(state)

    state = F0⊗X1 + F1⊗Z1
    op = N⊗X
    @test express(op*state) ≈ express(op)*express(state)
    @test express(op*state) ≈ express(F1⊗Z2)

    state = (3im*(2*dagger(Z1)+dagger(Y1))) * (3im*(2*X1+X2))

    cstate = CoherentState(im, inf_fock_basis)
    displace = DisplaceOp(im,inf_fock_basis)
    phase = PhaseShiftOp(im, inf_fock_basis)
    @test express(N*F1) ≈ express(N)*express(F1)
    @test express(Create*F1) ≈ express(Create)*express(F1)
    @test express(Destroy*F1) ≈ express(Destroy)*express(F1)
    @test express(displace*cstate) ≈ express(displace)*express(cstate)
end
