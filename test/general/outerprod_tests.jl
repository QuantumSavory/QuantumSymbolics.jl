@testitem "Outer Product" begin
    using QuantumOpticsBase

    @test isequal(L1*dagger(L0), SOuterKetBra(L1,dagger(L0)))

    @test isequal(express(L1*dagger(L0)), projector(express(L1), express(dagger(L0))))

end
