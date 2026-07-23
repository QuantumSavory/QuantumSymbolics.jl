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
end

if !hasproperty(QuantumOpticsRepr(), :lazy)
    # Exercise the lazy conversion path before QuantumInterface releases the native flag.
    const _test_lazy_quantumoptics_repr_key = :QuantumSymbolicsTestLazyQuantumOpticsRepr

    Base.propertynames(r::QuantumOpticsRepr, private::Bool=false) = (:cutoff, :lazy)
    function Base.getproperty(r::QuantumOpticsRepr, name::Symbol)
        name === :lazy && return get(task_local_storage(), _test_lazy_quantumoptics_repr_key, false)
        return getfield(r, name)
    end
    _test_lazy_repr() = QuantumOpticsRepr()
    _with_test_lazy_repr(f) = task_local_storage(f, _test_lazy_quantumoptics_repr_key, true)
    _with_test_eager_repr(f) = task_local_storage(f, _test_lazy_quantumoptics_repr_key, false)
else
    _test_lazy_repr() = QuantumOpticsRepr(lazy=true)
    _with_test_lazy_repr(f) = f()
    _with_test_eager_repr(f) = f()
end

_test_eager_qo(x) = _with_test_eager_repr() do
    express_nolookup(x, QuantumOpticsRepr())
end

@testset "Lazy QuantumOpticsRepr" begin
    using QuantumOpticsBase

    _with_test_lazy_repr() do
        repr = _test_lazy_repr()

        sum_expr = X + 2Y + Z
        lazy_sum = express(sum_expr, repr)
        @test lazy_sum isa LazySum
        @test length(lazy_sum.operators) == 3
        @test dense(lazy_sum) ≈ dense(_test_eager_qo(sum_expr))

        product_expr = X * (Y + Z)
        lazy_product = express(product_expr, repr)
        @test lazy_product isa LazyProduct
        @test lazy_product.operators[2] isa LazySum
        @test dense(lazy_product) ≈ dense(_test_eager_qo(product_expr))

        tensor_expr = X ⊗ Y ⊗ Z
        lazy_tensor = express(tensor_expr, repr)
        @test lazy_tensor isa LazyTensor
        @test length(lazy_tensor.operators) == 3
        @test dense(lazy_tensor) ≈ dense(_test_eager_qo(tensor_expr))

        nested_tensor_expr = X ⊗ (Y + Z)
        nested_lazy_tensor = express(nested_tensor_expr, repr)
        @test nested_lazy_tensor isa LazyTensor
        @test all(op -> op isa DataOperator, nested_lazy_tensor.operators)
        @test dense(nested_lazy_tensor) ≈ dense(_test_eager_qo(nested_tensor_expr))

        @test express(3 * product_expr, repr) isa LazyProduct
        @test express(3 * product_expr, repr).factor == 3
        @test express(3 * tensor_expr, repr) isa LazyTensor
        @test express(3 * tensor_expr, repr).factor == 3
    end
end
