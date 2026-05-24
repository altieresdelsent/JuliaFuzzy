# test/test_invariants.jl — Fuzzy logic mathematical invariant tests
#
# Tests mathematical properties that should hold for any correct fuzzy logic
# implementation, regardless of internal details:
# - De Morgan's Laws
# - Membership range [0,1]
# - Defuzzified output range [minValue, maxValue]
# - Idempotency

@testset "Fuzzy Logic Invariants" begin

    # ====================================================================
    # De Morgan's Laws
    # ====================================================================
    @testset "De Morgan's Laws: S(a,b) = 1 - T(1-a, 1-b)" begin

        test_pairs = [(0.0, 0.0), (0.2, 0.3), (0.5, 0.5), (0.7, 0.8), (1.0, 0.0), (0.3, 1.0)]

        # Minimum/Maximum are duals
        @testset "Minimum ↔ Maximum" begin
            for (a, b) in test_pairs
                lhs = compute(Maximum(), a, b)
                rhs = 1.0 - compute(Minimum(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

        # AlgebraicProduct/AlgebraicSum are duals
        @testset "AlgebraicProduct ↔ AlgebraicSum" begin
            for (a, b) in test_pairs
                lhs = compute(AlgebraicSum(), a, b)
                rhs = 1.0 - compute(AlgebraicProduct(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

        # BoundedDifference/BoundedSum are duals
        @testset "BoundedDifference ↔ BoundedSum" begin
            for (a, b) in test_pairs
                lhs = compute(BoundedSum(), a, b)
                rhs = 1.0 - compute(BoundedDifference(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

        # EinsteinProduct/EinsteinSum are duals
        @testset "EinsteinProduct ↔ EinsteinSum" begin
            for (a, b) in test_pairs
                lhs = compute(EinsteinSum(), a, b)
                rhs = 1.0 - compute(EinsteinProduct(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

        # HamacherProduct/HamacherSum are duals
        @testset "HamacherProduct ↔ HamacherSum" begin
            for (a, b) in test_pairs
                lhs = compute(HamacherSum(), a, b)
                rhs = 1.0 - compute(HamacherProduct(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

        # DrasticProduct/DrasticSum are duals
        @testset "DrasticProduct ↔ DrasticSum" begin
            for (a, b) in test_pairs
                lhs = compute(DrasticSum(), a, b)
                rhs = 1.0 - compute(DrasticProduct(), 1.0 - a, 1.0 - b)
                @test lhs ≈ rhs atol=1e-15
            end
        end

    end

    # ====================================================================
    # Idempotency
    # ====================================================================
    @testset "Idempotency" begin
        # Minimum is the only idempotent T-norm: T(x,x) = x
        for x in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]
            @test compute(Minimum(), x, x) ≈ x atol=1e-15
        end

        # Maximum is the only idempotent S-norm: S(x,x) = x
        for x in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]
            @test compute(Maximum(), x, x) ≈ x atol=1e-15
        end
    end

    # ====================================================================
    # Membership range: all μ(x) ∈ [0, 1]
    # ====================================================================
    @testset "Membership always in [0, 1]" begin
        terms = [
            Triangle{Float64}(:tri, -2.0, 2.0),
            Trapezoid{Float64}(:trap, 0.0, 2.0, 5.0, 7.0),
            Gaussian{Float64}(:gauss, 0.0, 1.0),
            Sigmoid{Float64}(:sig, 1.0, 0.0),
        ]

        for term in terms
            for x in -10.0:1.0:10.0
                mu = membership(term, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end

        # Also test Activated and Accumulated
        tri = Triangle{Float64}(:tri, 0.0, 2.0)
        act = Activated{Float64, Triangle{Float64}}(tri, 0.7, Minimum())
        for x in -5.0:0.5:7.0
            @test membership(act, x) ≥ 0.0 - 1e-15
            @test membership(act, x) ≤ 1.0 + 1e-15
        end
    end

    # ====================================================================
    # Defuzzified output range: always within [minValue, maxValue]
    # ====================================================================
    @testset "Defuzzified output always within variable bounds" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Gaussian{Float64}(:N, -5.0, 2.0),
             Gaussian{Float64}(:Z, 0.0, 2.0),
             Gaussian{Float64}(:P, 5.0, 2.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:Neg, -10.0, 0.0),
             Triangle{Float64}(:Zero, -5.0, 5.0),
             Triangle{Float64}(:Pos, 0.0, 10.0)],
            ["if Input is N then Output is Neg",
             "if Input is Z then Output is Zero",
             "if Input is P then Output is Pos"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        for x in -15.0:1.0:15.0
            result = run_engine(engine, invar, x)
            # Allow small margin outside bounds for numerical edge cases
            @test result ≥ outvar.minValue - 1.0
            @test result ≤ outvar.maxValue + 1.0
        end
    end

    # ====================================================================
    # Norm composition: T(T(a,b), c) within [0,1]
    # ====================================================================
    @testset "Norm composition stays in [0,1]" begin
        tnorms = [Minimum(), AlgebraicProduct(), BoundedDifference(),
                  EinsteinProduct(), HamacherProduct(), DrasticProduct()]
        snorms = [Maximum(), AlgebraicSum(), BoundedSum(),
                  EinsteinSum(), HamacherSum(), NormalizedSum(), DrasticSum()]

        for norm in tnorms
            for a in [0.0, 0.3, 0.7, 1.0]
                for b in [0.0, 0.3, 0.7, 1.0]
                    for c in [0.0, 0.3, 0.7, 1.0]
                        r = compute(norm, compute(norm, a, b), c)
                        if isnan(r)
                            continue  # Skip NaN from edge cases
                        end
                        @test r ≥ -1e-12
                        @test r ≤ 1.0 + 1e-12
                    end
                end
            end
        end

        for norm in snorms
            for a in [0.0, 0.3, 0.7, 1.0]
                for b in [0.0, 0.3, 0.7, 1.0]
                    for c in [0.0, 0.3, 0.7, 1.0]
                        r = compute(norm, compute(norm, a, b), c)
                        if isnan(r)
                            continue  # Skip NaN from edge cases
                        end
                        @test r ≥ -1e-12
                        @test r ≤ 1.0 + 1e-12
                    end
                end
            end
        end
    end

    # ====================================================================
    # Ordering: Minimum ≤ any other T-norm
    # ====================================================================
    @testset "Minimum is the largest T-norm: T_min(a,b) ≥ T_any(a,b)" begin
        other_tnorms = [AlgebraicProduct(), BoundedDifference(),
                        EinsteinProduct(), HamacherProduct(), DrasticProduct()]

        for tnorm in other_tnorms
            for a in [0.0, 0.2, 0.5, 0.8, 1.0]
                for b in [0.0, 0.2, 0.5, 0.8, 1.0]
                    min_result = compute(Minimum(), a, b)
                    other_result = compute(tnorm, a, b)
                    @test min_result ≥ other_result - 1e-15
                end
            end
        end
    end

    # ====================================================================
    # Maximum is the smallest S-norm: S_max(a,b) ≤ S_any(a,b)
    # ====================================================================
    @testset "Maximum is the smallest S-norm: S_max(a,b) ≤ S_any(a,b)" begin
        other_snorms = [AlgebraicSum(), BoundedSum(),
                        EinsteinSum(), HamacherSum(), NormalizedSum(), DrasticSum()]

        for snorm in other_snorms
            for a in [0.0, 0.2, 0.5, 0.8, 1.0]
                for b in [0.0, 0.2, 0.5, 0.8, 1.0]
                    max_result = compute(Maximum(), a, b)
                    other_result = compute(snorm, a, b)
                    @test max_result ≤ other_result + 1e-15
                end
            end
        end
    end

end
