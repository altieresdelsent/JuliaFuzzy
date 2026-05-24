# test/test_snorms.jl — S-Norm mathematical property tests
#
# Tests all 7 S-norms against fuzzy logic axioms:
# - Boundary conditions
# - Commutativity
# - Monotonicity (S(a,b) ≥ max(a,b))
# - Known analytical values
#
# S-norms tested: Maximum, AlgebraicSum, BoundedSum, EinsteinSum,
#                  HamacherSum, NormalizedSum, DrasticSum

@testset "S-Norms (Disjunction / OR)" begin

    # === Test data ===
    snorms = [
        ("Maximum", Maximum()),
        ("AlgebraicSum", AlgebraicSum()),
        ("BoundedSum", BoundedSum()),
        ("EinsteinSum", EinsteinSum()),
        ("HamacherSum", HamacherSum()),
        ("NormalizedSum", NormalizedSum()),
        ("DrasticSum", DrasticSum()),
    ]

    test_pairs = [
        (0.0, 0.0), (0.0, 0.3), (0.0, 0.7), (0.0, 1.0),
        (0.3, 0.0), (0.3, 0.3), (0.3, 0.7), (0.3, 1.0),
        (0.7, 0.0), (0.7, 0.3), (0.7, 0.7), (0.7, 1.0),
        (1.0, 0.0), (1.0, 0.3), (1.0, 0.7), (1.0, 1.0),
    ]

    for (name, snorm) in snorms
        @testset "$name" begin

            # === Boundary conditions ===
            # S(0, 0) = 0
            @test compute(snorm, 0.0, 0.0) ≈ 0.0 atol=1e-15
            # S(0, 1) = 1
            @test compute(snorm, 0.0, 1.0) ≈ 1.0 atol=1e-15
            # S(1, 0) = 1
            @test compute(snorm, 1.0, 0.0) ≈ 1.0 atol=1e-15
            # S(1, 1) = 1
            @test compute(snorm, 1.0, 1.0) ≈ 1.0 atol=1e-15

            # === Commutativity: S(a,b) = S(b,a) ===
            for (a, b) in test_pairs
                @test compute(snorm, a, b) ≈ compute(snorm, b, a) atol=1e-15
            end

            # === Monotonicity: S(a,b) ≥ max(a,b) ===
            # This is a defining property of all S-norms
            for (a, b) in test_pairs
                result = compute(snorm, a, b)
                @test result ≥ max(a, b) - 1e-15
            end

            # === Range: S(a,b) ∈ [0, 1] ===
            for (a, b) in test_pairs
                result = compute(snorm, a, b)
                @test result ≥ 0.0 - 1e-15
                @test result ≤ 1.0 + 1e-15
            end

            # === Associativity: S(a, S(b,c)) = S(S(a,b), c) ===
            for a in [0.0, 0.25, 0.5, 0.75, 1.0]
                for b in [0.0, 0.25, 0.5, 0.75, 1.0]
                    for c in [0.0, 0.25, 0.5, 0.75, 1.0]
                        left = compute(snorm, a, compute(snorm, b, c))
                        right = compute(snorm, compute(snorm, a, b), c)
                        @test left ≈ right atol=1e-12
                    end
                end
            end

            # === Identity: S(a, 0) = a ===
            for a in [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]
                @test compute(snorm, a, 0.0) ≈ a atol=1e-15
                @test compute(snorm, 0.0, a) ≈ a atol=1e-15
            end

        end
    end

    # === Known analytical values ===
    @testset "Known analytical values" begin

        # Maximum
        @test compute(Maximum(), 0.3, 0.7) ≈ 0.7
        @test compute(Maximum(), 0.5, 0.5) ≈ 0.5
        @test compute(Maximum(), 0.0, 0.5) ≈ 0.5

        # AlgebraicSum: S(a,b) = a + b - a*b
        @test compute(AlgebraicSum(), 0.3, 0.4) ≈ 0.3 + 0.4 - 0.12  # = 0.58
        @test compute(AlgebraicSum(), 0.5, 0.5) ≈ 0.75
        @test compute(AlgebraicSum(), 0.0, 0.5) ≈ 0.5
        @test compute(AlgebraicSum(), 1.0, 0.5) ≈ 1.0

        # BoundedSum: S(a,b) = min(1, a+b)
        @test compute(BoundedSum(), 0.3, 0.4) ≈ 0.7
        @test compute(BoundedSum(), 0.6, 0.7) ≈ 1.0
        @test compute(BoundedSum(), 0.2, 0.2) ≈ 0.4

        # EinsteinSum: S(a,b) = (a+b) / (1 + a*b)
        @test compute(EinsteinSum(), 0.0, 0.5) ≈ 0.5
        @test compute(EinsteinSum(), 1.0, 0.5) ≈ 1.0
        # EinsteinSum(0.5, 0.5) = 1.0 / 1.25 = 0.8
        @test compute(EinsteinSum(), 0.5, 0.5) ≈ 0.8 atol=1e-15

        # HamacherSum: S(a,b) = (a+b-2ab) / (1-ab)
        @test compute(HamacherSum(), 0.0, 0.5) ≈ 0.5
        @test compute(HamacherSum(), 1.0, 0.5) ≈ 1.0
        # HamacherSum(0.5, 0.5) = (0.5+0.5-0.5) / (1-0.25) = 0.5/0.75 = 2/3
        @test compute(HamacherSum(), 0.5, 0.5) ≈ 2.0/3.0 atol=1e-12

        # DrasticSum
        @test compute(DrasticSum(), 0.5, 0.3) ≈ 1.0
        @test compute(DrasticSum(), 0.0, 0.3) ≈ 0.3
        @test compute(DrasticSum(), 0.7, 0.0) ≈ 0.7
        @test compute(DrasticSum(), 0.0, 0.0) ≈ 0.0

    end

    # === Monotonicity (non-decreasing in each argument) ===
    @testset "Monotonicity (non-decreasing)" begin
        for (name, snorm) in snorms
            for a in [0.0, 0.2, 0.5, 0.8]
                for b1 in [0.0, 0.3, 0.6]
                    for b2 in [0.0, 0.3, 0.6]
                        if b1 ≤ b2
                            @test compute(snorm, a, b1) ≤ compute(snorm, a, b2) + 1e-15
                        end
                    end
                end
            end
        end
    end

end
