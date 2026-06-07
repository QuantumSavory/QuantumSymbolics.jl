using Test
using QuantumSymbolics

@testset "Test qo" begin
    using QuantumOptics
    using QuantumSymbolics
    #using QuantumOpticsExt: LazyPrePost
    LazyPrePost = Base.get_extension(QuantumSymbolics, :QuantumOpticsExt).LazyPrePost

    bs = GenericBasis(2),GenericBasis(2)
    op0 = Operator(bs...,rand(2,2))
    op21 = Operator(bs...,rand(2,2))
    op22 = Operator(bs...,rand(2,2))
    op31 = Operator(bs...,rand(2,2))
    op32 = Operator(bs...,rand(2,2))
    l2 = LazyPrePost(op21,op22)
    l3 = LazyPrePost(op31,op32)
    @test spre(op21)*spost(op22) ≈ spost(op22)*spre(op21)
    @test spre(op21)*spost(op22)*op0 ≈ l2*op0
    @test spre(op31)*spost(op32)*spre(op21)*spost(op22)*op0 ≈ (l3*l2)*op0 ≈ l3*(l2*op0)
    @test (l2+l3) * op0 ≈ spre(op21)*spost(op22)*op0 + spre(op31)*spost(op32)*op0

    op0a = Operator(bs...,rand(2,2))
    op0b = Operator(bs...,rand(2,2))
    opt0 = op0⊗op0a⊗op0b
    b = basis(opt0)
    @test embed(b,b,[1],l2)*opt0 ≈ (spre(op21)*spost(op22)*op0)⊗op0a⊗op0b
    @test embed(b,b,[1],l2+l3)*opt0 ≈ (spre(op21)*spost(op22)*op0 + spre(op31)*spost(op32)*op0)⊗op0a⊗op0b

    lazy_repr = QuantumOpticsRepr(lazy=true)
    eager_repr = QuantumOpticsRepr()

    sum_op = (QuantumSymbolics.X ⊗ QuantumSymbolics.I) + (QuantumSymbolics.I ⊗ QuantumSymbolics.Z)
    lazy_sum = express(sum_op, lazy_repr)
    @test lazy_sum isa LazySum
    @test dense(lazy_sum) ≈ express(sum_op, eager_repr)

    product_op = (QuantumSymbolics.X ⊗ QuantumSymbolics.I) * (QuantumSymbolics.I ⊗ QuantumSymbolics.Z)
    lazy_product = express(product_op, lazy_repr)
    @test lazy_product isa LazyProduct
    @test dense(lazy_product) ≈ express(product_op, eager_repr)

    tensor_op = QuantumSymbolics.X ⊗ QuantumSymbolics.Z
    lazy_tensor = express(tensor_op, lazy_repr)
    @test lazy_tensor isa LazyTensor
    @test dense(lazy_tensor) ≈ express(tensor_op, eager_repr)

    commutator_op = commutator(QuantumSymbolics.X, QuantumSymbolics.Z)
    lazy_commutator = express(commutator_op, lazy_repr)
    @test lazy_commutator isa LazySum
    @test dense(lazy_commutator) ≈ express(commutator_op, eager_repr)
end
