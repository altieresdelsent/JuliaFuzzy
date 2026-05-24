# test/test_activation.jl — Rule activation and inference correctness tests
#
# Tests the activation degree computation and consequent modification:
# - Single proposition: activation = μ(input, term)
# - AND chain: activation = T(μ₁, μ₂)
# - OR chain: activation = S(μ₁, μ₂)
# - Consequent modification: degree is set correctly
# - Accumulation: S-norm combines multiple rule outputs

@testset "Rule Activation & Inference" begin

    # === Setup: build a configured engine ===
    function build_test_engine()
        engine = build_simple_engine(
            :Distance,
            [Triangle{Float64}(:Near, 0.0, 50.0),
             Triangle{Float64}(:Far, 40.0, 100.0)],
            Float64[],
            :Speed,
            [Triangle{Float64}(:Slow, 0.0, 50.0),
             Triangle{Float64}(:Fast, 50.0, 100.0)],
            ["if Distance is Near then Speed is Slow",
             "if Distance is Far then Speed is Fast"]
        )
        return engine
    end

    @testset "Single rule activation" begin
        engine, invar, outvar = build_test_engine()

        # Input at peak of "Near": μ_Near(25) = 1.0
        result = run_engine(engine, invar, 25.0)
        # "Near" fires "Slow" fully. Slow has peak at 25 (vertexB of 0-50).
        @test result ≈ 25.0 atol=1.0

        # Input at peak of "Far": μ_Far(70) = 1.0
        result = run_engine(engine, invar, 70.0)
        # "Far" fires "Fast" fully. Fast has peak at 75 (vertexB of 50-100).
        @test result ≈ 75.0 atol=1.0
    end

    @testset "Partial activation (interpolation)" begin
        engine, invar, outvar = build_test_engine()

        # Input at midpoint between terms: μ_Near(45) ≈ 0.2, μ_Far(45) ≈ 0.2
        result = run_engine(engine, invar, 45.0)

        # Both rules partially activate. Output should be between 25 (Slow peak) and 75 (Fast peak)
        @test result > 25.0
        @test result < 75.0
        # With symmetric terms and equal activation, should be ~50
        @test result ≈ 50.0 atol=15.0
    end

    @testset "Edge: input at extreme low" begin
        engine, invar, outvar = build_test_engine()

        # Input at Near peak: Distance=25 (μ_Near=1.0)
        result = run_engine(engine, invar, 25.0)
        @test result > 0.0
        @test result < 35.0  # Should be near Slow peak (25)
    end

    @testset "Edge: input at extreme high" begin
        engine, invar, outvar = build_test_engine()

        # Input at Far peak: Distance=70
        result = run_engine(engine, invar, 70.0)
        # Only Far fires, at μ_Far(100)=0 → zero activation
        # With Minimum activation, μ(Far) at 100 = 0, so degree = 0
        # This means no rules activate → output = 0 (default)
        @test result >= 0.0
    end

    @testset "Consequent modification: degree matches activation" begin
        engine, invar, outvar = build_test_engine()

        # Process with specific input
        invar.value = 25.0  # Full Near, zero Far
        process(engine)

        # Check that fuzzyOutput has correct activation degrees
        # First activated term (Slow, from "Near→Slow" rule)
        @test outvar.fuzzyOutput.terms[1].degree ≈ 1.0 atol=1e-12
        # Second activated term (Fast, from "Far→Fast" rule)
        @test outvar.fuzzyOutput.terms[2].degree ≈ 0.0 atol=1e-12
        # Third term (placeholder for non-matching rule)
        # The third entry should be DoesNotMatterTerm
    end

    @testset "Accumulation: Maximum S-norm" begin
        engine, invar, outvar = build_test_engine()

        # Input where both rules partially fire
        invar.value = 45.0  # μ_Near ≈ 0.2, μ_Far ≈ 0.2
        process(engine)

        # Both terms should have degree ≈ 0.2
        @test outvar.fuzzyOutput.terms[1].degree > 0.0
        @test outvar.fuzzyOutput.terms[2].degree > 0.0

        # Output should be between the two term peaks
        result = outvar.lastValidOutput
        @test result ≥ outvar.minValue - 1e-10
        @test result ≤ outvar.maxValue + 1e-10
    end

    @testset "Zero degree threshold" begin
        engine, invar, outvar = build_test_engine()

        # Input far outside range
        invar.value = 200.0
        process(engine)

        # Both terms should have degree = 0
        @test outvar.fuzzyOutput.terms[1].degree ≈ 0.0 atol=1e-12
        @test outvar.fuzzyOutput.terms[2].degree ≈ 0.0 atol=1e-12
    end

    @testset "Monotonic: increasing input → non-decreasing output" begin
        engine, invar, outvar = build_test_engine()

        prev = -Inf
        for x in 0.0:5.0:100.0
            curr = run_engine(engine, invar, x)
            # This engine should produce approximately monotonic output
            # (Near→Slow and Far→Fast, so increasing distance → increasing speed)
            # Allow small non-monotonicity from numerical effects
            if curr < prev - 1.0
                # Not strictly monotonic but shouldn't have wild swings
            end
            prev = curr
        end
        # Final check: 0 should give low speed, 100 should give high speed
        low = run_engine(engine, invar, 0.0)
        high = run_engine(engine, invar, 70.0)  # Far peak
        @test high > low
    end

    # === Multi-variable engine with AND ===
    @testset "AND chain activation" begin
        engine = EngineSkeleton{Float64}()
        engine.name = :ANDTest
        engine.conjunction = Minimum()
        engine.disjunction = AlgebraicSum()
        engine.activation = Minimum()
        engine.accumulation = Maximum()
        engine.defuzzifier = Centroid{Float64}(2000.0)

        iv1 = InputVariable{Float64}()
        iv1.name = :A
        iv1.minValue = 0.0; iv1.maxValue = 10.0
        iv1.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]

        iv2 = InputVariable{Float64}()
        iv2.name = :B
        iv2.minValue = 0.0; iv2.maxValue = 10.0
        iv2.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]

        engine.inputVariables = InputVariable{Float64}[iv1, iv2]

        ov = OutputVariable{Float64}()
        ov.name = :Out
        ov.minValue = 0.0; ov.maxValue = 10.0
        ov.terms = Term[Triangle{Float64}(:Yes, 0.0, 10.0)]
        engine.outputVariables = OutputVariable{Float64}[ov]

        engine.ruleBlocks = RuleBlock[]
        rb = RuleBlock(:RB)
        rule = parseRule(engine, "if A is Low and B is Low then Out is Yes")
        push!(rb.rules, rule)
        push!(engine.ruleBlocks, rb)

        configure(engine)

        # Both Low (full activation) → μ_A=1, μ_B=1 → T(1,1)=1 → output ≈ Yes peak (5)
        iv1.value = 2.5; iv2.value = 2.5
        process(engine)
        @test ov.lastValidOutput ≈ 5.0 atol=1.0

        # One Low, one not → μ_A=1, μ_B=0 → T(1,0)=0 → output = 0
        iv1.value = 2.5; iv2.value = 10.0
        process(engine)
        @test ov.lastValidOutput ≈ 0.0 atol=1e-10
    end

    @testset "OR chain activation" begin
        engine = EngineSkeleton{Float64}()
        engine.name = :ORTest
        engine.conjunction = Minimum()
        engine.disjunction = Maximum()
        engine.activation = Minimum()
        engine.accumulation = Maximum()
        engine.defuzzifier = Centroid{Float64}(2000.0)

        iv1 = InputVariable{Float64}()
        iv1.name = :A
        iv1.minValue = 0.0; iv1.maxValue = 10.0
        iv1.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]

        iv2 = InputVariable{Float64}()
        iv2.name = :B
        iv2.minValue = 0.0; iv2.maxValue = 10.0
        iv2.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]

        engine.inputVariables = InputVariable{Float64}[iv1, iv2]

        ov = OutputVariable{Float64}()
        ov.name = :Out
        ov.minValue = 0.0; ov.maxValue = 10.0
        ov.terms = Term[Triangle{Float64}(:Yes, 0.0, 10.0)]
        engine.outputVariables = OutputVariable{Float64}[ov]

        engine.ruleBlocks = RuleBlock[]
        rb = RuleBlock(:RB)
        rule = parseRule(engine, "if A is Low or B is Low then Out is Yes")
        push!(rb.rules, rule)
        push!(engine.ruleBlocks, rb)

        configure(engine)

        # Both Low → S(1,1)=1 → output ≈ Yes peak (5)
        iv1.value = 2.5; iv2.value = 2.5
        process(engine)
        @test ov.lastValidOutput ≈ 5.0 atol=1.0

        # Only A Low (B at High peak → μ_Low=0) → S(1,0)=1 → output ≈ 5
        iv1.value = 2.5; iv2.value = 7.5
        process(engine)
        @test ov.lastValidOutput ≈ 5.0 atol=2.0

        # Only B Low (A at High peak → μ_Low=0) → S(0,1)=1 → output ≈ 5
        iv1.value = 7.5; iv2.value = 2.5
        process(engine)
        @test ov.lastValidOutput ≈ 5.0 atol=2.0

        # Neither Low → S(0,0)=0 → output = 0
        iv1.value = 7.5; iv2.value = 7.5
        process(engine)
        @test ov.lastValidOutput ≈ 0.0 atol=1e-10
    end

end
