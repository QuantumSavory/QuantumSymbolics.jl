@testitem "QuantumToolbox objects" begin
    using QuantumSymbolics
    using QuantumToolbox

    α = rand(ComplexF64)
    n = rand(1:9)

    @testset "Fock states and operators" begin
        repr = QuantumToolboxRepr(cutoff = 10)
        @test express(vac, repr) ≈ fock(10, 0)
        @test express(FockState(n), repr) ≈ fock(10, n)
        @test express(CoherentState(α), repr) ≈ coherent(10, α)
        @test express(SqueezedState(α), repr) ≈ squeeze(10, α) * fock(10, 0)
        @test express(NumberOp(), repr) ≈ num(10)
        @test express(CreateOp(), repr) ≈ create(10)
        @test express(DestroyOp(), repr) ≈ destroy(10)
        @test express(DisplaceOp(α), repr) ≈ displace(10, α)
    end

    @testset "Quantum gates" begin
        repr = QuantumToolboxRepr()
        @test express(H, repr) ≈ to_sparse(Qobj([1.0+0.0im 1.; 1. -1.]/√2))
        @test express(X, repr) ≈ sigmax()
        @test express(Y, repr) ≈ sigmay()
        @test express(Z, repr) ≈ sigmaz()
        @test express(CPHASE, repr) ≈ Qobj([1.0+0.0im 0. 0. 0.; 0. 1. 0. 0.; 0. 0. 1. 0.; 0. 0. 0. -1.], dims = (2,2))
        @test express(CNOT, repr) ≈ Qobj([1.0+0.0im 0. 0. 0.; 0. 1. 0. 0.; 0. 0. 0. 1.; 0. 0. 1. 0.], dims = (2,2))
        @test express(QuantumSymbolics.PauliM(), repr) ≈ sigmam()
        @test express(QuantumSymbolics.PauliP(), repr) ≈ sigmap()
    end

    @testset "Pure states" begin
        repr = QuantumToolboxRepr()
        @test express(XBasisState(1, SpinBasis(1//2)), repr) ≈ Qobj([1.0+0.0im, 1.0]/√2)
        @test express(XBasisState(2, SpinBasis(1//2)), repr) ≈ Qobj([1.0+0.0im, -1.0]/√2)
        @test express(YBasisState(1, SpinBasis(1//2)), repr) ≈ Qobj([1.0+0.0im, 1.0im]/√2)
        @test express(YBasisState(2, SpinBasis(1//2)), repr) ≈ Qobj([1.0+0.0im, -1.0im]/√2)
        @test express(ZBasisState(1, SpinBasis(1//2)), repr) ≈ Qobj([1.0+0.0im, 0.0])
        @test express(ZBasisState(2, SpinBasis(1//2)), repr) ≈ Qobj([0.0+0.0im, 1.0])
    end

    @testset "Linear algebra" begin
        repr = QuantumToolboxRepr()
        @test express(QuantumSymbolics.tensor(X, Y) + QuantumSymbolics.tensor(Z, X), repr) ≈ QuantumToolbox.tensor(express(X, repr), express(Y, repr)) + QuantumToolbox.tensor(express(Z, repr), express(X, repr))
        @test express(CreateOp() * (FockState(1) + CoherentState(α)), repr) ≈ express(CreateOp(), repr) * (express(FockState(1), repr) + express(CoherentState(α), repr))
        @test express(IdentityOp(QuantumSymbolics.tensor(X, Y)), repr) ≈ qeye(4)
        @test express(MixedState(QuantumSymbolics.tensor(X, Y)), repr) ≈ qeye(4) / 4
    end
end