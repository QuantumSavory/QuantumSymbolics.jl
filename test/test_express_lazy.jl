@testitem "Express Lazy" begin
    using QuantumOpticsBase

    state = 1im*X2⊗Z1+2*Y1⊗(Z2+X2)+StabilizerState("XZ YY")
    repr = QuantumOpticsExt()
    repr_lazy = QuantumOpticsExt(lazy=true)
    
    isequal(express(X1, repr_lazy), express(X1, repr))
    isequal(express(X2, repr_lazy), express(X2, repr))
    isequal(express(Y1, repr_lazy), express(Y1, repr))
    isequal(express(Y2, repr_lazy), express(Y2, repr))
    isequal(express(Z1, repr_lazy), express(Z1, repr))
    isequal(express(Z2, repr_lazy), express(Z2, repr))
end
