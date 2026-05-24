# test/test_tnorms.jl — T-Norm mathematical property tests
#
# Tests all 6 T-norms against fuzzy logic axioms:
# - Boundary conditions
# - Commutativity
# - Monotonicity (T(a,b) ≤ min(a,b))
# - Known analytical values
#
# T-norms tested: Minimum, AlgebraicProduct, BoundedDifference,
#                  EinsteinProduct, HamacherProduct, DrasticProduct

@testset "T-Norms (Conjunction / AND)" begin

    # === Test data ===
    tnorms = [
        ("Minimum", Minimum()),
        ("AlgebraicProduct", AlgebraicProduct()),
        ("BoundedDifference", BoundedDifference()),
        ("EinsteinProduct", EinsteinProduct()),
        ("HamacherProduct", HamacherProduct()),
        ("DrasticProduct", DrasticProduct()),
    ]

    test_pairs = [
        (0.0, 0.0), (0.0, 0.3), (0.0, 0.7), (0.0, 1.0),
        (0.3, 0.0), (0.3, 0.3), (0.3, 0.7), (0.3, 1.0),
        (0.7, 0.0), (0.7, 0.3), (0.7, 0.7), (0.7, 1.0),
        (1.0, 0.0), (1.0, 0.3), (1.0, 0.7), (1.0, 1.0),
    ]

    for (name, tnorm) in tnorms
        @testset "$name" begin

            # === Boundary conditions ===
            # T(0, 0) = 0
            @test compute(tnorm, 0.0, 0.0) ≈ 0.0 atol=1e-15
            # T(0, 1) = 0
            @test compute(tnorm, 0.0, 1.0) ≈ 0.0 atol=1e-15
            # T(1, 0) = 0
            @test compute(tnorm, 1.0, 0.0) ≈ 0.0 atol=1e-15
            # T(1, 1) = 1
            @test compute(tnorm, 1.0, 1.0) ≈ 1.0 atol=1e-15

            # === Commutativity: T(a,b) = T(b,a) ===
            for (a, b) in test_pairs
                @test compute(tnorm, a, b) ≈ compute(tnorm, b, a) atol=1e-15
            end

            # === Monotonicity: T(a,b) ≤ min(a,b) ===
            # This is a defining property of all T-norms
            for (a, b) in test_pairs
                result = compute(tnorm, a, b)
                @test result ≤ min(a, b) + 1e-15
            end

            # === Range: T(a,b) ∈ [0, 1] ===
            for (a, b) in test_pairs
                result = compute(tnorm, a, b)
                @test result ≥ 0.0 - 1e-15
                @test result ≤ 1.0 + 1e-15
            end

            # === Associativity: T(a, T(b,c)) = T(T(a,b), c) ===
            # Test for selected triples
            for a in [0.0, 0.25, 0.5, 0.75, 1.0]
                for b in [0.0, 0.25, 0.5, 0.75, 1.0]
                    for c in [0.0, 0.25, 0.5, 0.75, 1.0]
                        left = compute(tnorm, a, compute(tnorm, b, c))
                        right = compute(tnorm, compute(tnorm, a, b), c)
                        @test left ≈ right atol=1e-12
                    end
                end
            end

            # === Identity: T(a, 1) = a ===
            for a in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]
                @test compute(tnorm, a, 1.0) ≈ a atol=1e-15
                @test compute(tnorm, 1.0, a) ≈ a atol=1e-15
            end

        end
    end

    # === Known analytical values ===
    @testset "Known analytical values" begin

        # Minimum
        @test compute(Minimum(), 0.3, 0.7) ≈ 0.3
        @test compute(Minimum(), 0.5, 0.5) ≈ 0.5
        @test compute(Minimum(), 0.0, 0.5) ≈ 0.0

        # AlgebraicProduct
        @test compute(AlgebraicProduct(), 0.3, 0.4) ≈ 0.12
        @test compute(AlgebraicProduct(), 0.5, 0.5) ≈ 0.25
        @test compute(AlgebraicProduct(), 0.0, 0.5) ≈ 0.0
        @test compute(AlgebraicProduct(), 1.0, 0.5) ≈ 0.5

        # BoundedDifference
        @test compute(BoundedDifference(), 0.6, 0.7) ≈ 0.3
        @test compute(BoundedDifference(), 0.3, 0.4) ≈ 0.0
        @test compute(BoundedDifference(), 0.8, 0.9) ≈ 0.7
        @test compute(BoundedDifference(), 0.2, 0.2) ≈ 0.0

        # EinsteinProduct
        @test compute(EinsteinProduct(), 0.0, 0.5) ≈ 0.0
        @test compute(EinsteinProduct(), 1.0, 0.5) ≈ 0.5
        # EinsteinProduct(0.5, 0.5) = 0.25 / (2 - (0.5+0.5-0.25)) = 0.25/1.25 = 0.2
        @test compute(EinsteinProduct(), 0.5, 0.5) ≈ 0.2 atol=1e-15

        # HamacherProduct
        @test compute(HamacherProduct(), 0.0, 0.5) ≈ 0.0
        @test compute(HamacherProduct(), 1.0, 0.5) ≈ 0.5
        # HamacherProduct(0.5, 0.5) = 0.25 / (0.5+0.5-0.25) = 0.25/0.75 = 1/3
        @test compute(HamacherProduct(), 0.5, 0.5) ≈ 1.0/3.0 atol=1e-12

        # DrasticProduct
        @test compute(DrasticProduct(), 0.5, 0.3) ≈ 0.0
        @test compute(DrasticProduct(), 1.0, 0.3) ≈ 0.3
        @test compute(DrasticProduct(), 0.7, 1.0) ≈ 0.7
        @test compute(DrasticProduct(), 0.5, 0.5) ≈ 0.0
    end

    # === Monotonicity (non-decreasing in each argument) ===
    @testset "Monotonicity (non-decreasing)" begin
        for (name, tnorm) in tnorms
            for a in [0.0, 0.2, 0.5, 0.8]
                for b1 in [0.0, 0.3, 0.6]
                    for b2 in [0.0, 0.3, 0.6]
                        if b1 ≤ b2
                            @test compute(tnorm, a, b1) ≤ compute(tnorm, a, b2) + 1e-15
                        end
                    end
                end
            end
        end
    end

end
