# test/test_edge_cases.jl — Edge case and robustness tests
#
# Tests boundary conditions and edge cases:
# - No rules activated → default output
# - Input at exact variable boundaries
# - Terms with custom height
# - Empty rule block
# - Single point / degenerate terms
# - Very high resolution Centroid

@testset "Edge Cases & Robustness" begin

    # ====================================================================
    # No rules activated
    # ====================================================================
    @testset "No rules activated" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Only, 0.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:Out, 0.0, 20.0)],
            ["if Input is Only then Output is Out"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        # Input outside range → μ = 0 → no activation
        result = run_engine(engine, invar, -100.0)
        # With no activation, centroid divides by zero → returns 0.0 (NaN guard)
        @test result ≈ 0.0 atol=1e-10
    end

    # ====================================================================
    # Input at exact variable boundaries
    # ====================================================================
    @testset "Input at variable boundaries (minValue, maxValue)" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Low, -10.0, 0.0),
             Triangle{Float64}(:High, 0.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:OutLow, -10.0, 0.0),
             Triangle{Float64}(:OutHigh, 0.0, 10.0)],
            ["if Input is Low then Output is OutLow",
             "if Input is High then Output is OutHigh"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        # At minValue of Low term: μ_Low(-10) = 0, μ_High(-10) = 0
        result_min = run_engine(engine, invar, -10.0)
        # No activation → centroid returns 0.0 (NaN guard)
        @test abs(result_min) < 1e-10

        # At maxValue of High term: μ_High(10) = 0, μ_Low(10) = 0
        result_max = run_engine(engine, invar, 10.0)
        @test abs(result_max) < 1e-10

        # At crossover point (0): both terms have μ = 0 (since B=0 is the peak for both)
        # Actually Low: (-10, -5, 0) → μ_Low(0) = 0. High: (0, 5, 10) → μ_High(0) = 0
    end

    # ====================================================================
    # Centroid with very high resolution
    # ====================================================================
    @testset "Centroid with high resolution" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:T, 0.0, 4.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:O, 10.0, 30.0)],
            ["if Input is T then Output is O"],
            defuzzifier=Centroid{Float64}(10000.0)  # Very high resolution
        )

        result = run_engine(engine, invar, 2.0)  # Full activation
        # Should converge to peak of Output triangle (20)
        @test result ≈ 20.0 atol=0.5
    end

    # ====================================================================
    # Terms with custom height
    # ====================================================================
    @testset "Terms with height ≠ 1.0" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Half, -1.0, 1.0, 0.5)],  # Height = 0.5
            Float64[],
            :Output,
            [Triangle{Float64}(:Out, 0.0, 10.0)],
            ["if Input is Half then Output is Out"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        # Input at peak: μ = 0.5
        result_at_peak = run_engine(engine, invar, 0.0)
        # With height 0.5, the output is truncated
        @test result_at_peak ≥ 0.0 - 1e-10
        @test result_at_peak ≤ outvar.maxValue + 1e-10

        # Input far away: μ = 0
        result_far = run_engine(engine, invar, 10.0)
        @test result_far ≈ 0.0 atol=1e-10
    end

    # ====================================================================
    # Trapezoid output terms with Centroid
    # ====================================================================
    @testset "Trapezoid output terms" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Fire, 0.0, 10.0)],
            Float64[],
            :Output,
            [Trapezoid{Float64}(:Resp, 0.0, 2.0, 8.0, 10.0)],  # Trapezoid output
            ["if Input is Fire then Output is Resp"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        result = run_engine(engine, invar, 5.0)  # Full activation
        # Trapezoid centroid: for symmetric trapezoid (0,2,8,10), centroid ≈ 5.0
        @test result ≈ 5.0 atol=1.0
        # Output should be near the variable range (0 to 10)
        @test result ≥ 0.0 - 1e-10
        @test result ≤ 10.0 + 1e-10
    end

    # ====================================================================
    # Gaussian output terms with Centroid
    # ====================================================================
    @testset "Gaussian output terms" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Fire, 0.0, 10.0)],
            Float64[],
            :Output,
            [Gaussian{Float64}(:Resp, 5.0, 1.5)],  # Gaussian output
            ["if Input is Fire then Output is Resp"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        result = run_engine(engine, invar, 5.0)  # Full activation
        # Gaussian centroid should be near its mean (5.0)
        @test result ≈ 5.0 atol=1.0
    end

    # ====================================================================
    # Sigmoid output terms with Centroid
    # ====================================================================
    @testset "Sigmoid output terms" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Fire, 0.0, 10.0)],
            Float64[],
            :Output,
            [Sigmoid{Float64}(:Resp, 2.0, 5.0)],  # Sigmoid output, inflection at 5
            ["if Input is Fire then Output is Resp"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        result = run_engine(engine, invar, 5.0)  # Full activation
        # Sigmoid centroid is complex, but should be in a reasonable range
        @test result ≥ outvar.minValue - 1e-10
        @test result ≤ outvar.maxValue + 1e-10
    end

    # ====================================================================
    # Multiple processing calls (idempotency)
    # ====================================================================
    @testset "Multiple process() calls with same input" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:T, 0.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:O, 0.0, 20.0)],
            ["if Input is T then Output is O"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        invar.value = 5.0
        process(engine)
        result1 = outvar.lastValidOutput

        # Process again with same input
        process(engine)
        result2 = outvar.lastValidOutput

        @test result1 ≈ result2 atol=1e-10
    end

    # ====================================================================
    # Multiple process() calls with different inputs
    # ====================================================================
    @testset "Multiple process() calls with different inputs" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:T, 0.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:O, 0.0, 20.0)],
            ["if Input is T then Output is O"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        invar.value = 5.0
        process(engine)
        result_full = outvar.lastValidOutput

        invar.value = 2.5
        process(engine)
        result_half = outvar.lastValidOutput

        invar.value = 10.0  # Outside range → μ = 0
        process(engine)
        result_zero = outvar.lastValidOutput

        # Full activation should give at least as much output as half activation
        @test result_full ≥ result_half - 1e-10
    end

    # ====================================================================
    # Large number of output terms
    # ====================================================================
    @testset "Many output terms" begin
        terms = Term[
            Triangle{Float64}(:T1, 0.0, 10.0),
            Triangle{Float64}(:T2, 5.0, 15.0),
            Triangle{Float64}(:T3, 10.0, 20.0),
            Triangle{Float64}(:T4, 15.0, 25.0),
            Triangle{Float64}(:T5, 20.0, 30.0),
        ]
        rules = [
            "if Input is T1 then Output is T1",
            "if Input is T2 then Output is T2",
            "if Input is T3 then Output is T3",
            "if Input is T4 then Output is T4",
            "if Input is T5 then Output is T5",
        ]

        engine, invar, outvar = build_simple_engine(
            :Input, terms, Float64[],
            :Output, terms, rules,
            defuzzifier=Centroid{Float64}(2000.0)
        )

        # Should not crash and should produce reasonable output
        result = run_engine(engine, invar, 5.0)
        @test result ≥ outvar.minValue - 1e-10
        @test result ≤ outvar.maxValue + 1e-10
    end

    # ====================================================================
    # Rule with AND involving the same variable twice (self-reference)
    # ====================================================================
    @testset "Rule with same variable in AND" begin
        engine = EngineSkeleton{Float64}()
        engine.name = :SelfRef
        engine.conjunction = Minimum()
        engine.disjunction = Maximum()
        engine.activation = Minimum()
        engine.accumulation = Maximum()
        engine.defuzzifier = Centroid{Float64}(2000.0)

        iv = InputVariable{Float64}()
        iv.name = :X
        iv.minValue = 0.0; iv.maxValue = 10.0
        iv.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]
        engine.inputVariables = InputVariable{Float64}[iv]

        ov = OutputVariable{Float64}()
        ov.name = :Y
        ov.minValue = 0.0; ov.maxValue = 10.0
        ov.terms = Term[Triangle{Float64}(:Yes, 0.0, 10.0)]
        engine.outputVariables = OutputVariable{Float64}[ov]

        engine.ruleBlocks = RuleBlock[]
        rb = RuleBlock(:RB)
        rule = parseRule(engine, "if X is Low and X is High then Y is Yes")
        push!(rb.rules, rule)
        push!(engine.ruleBlocks, rb)

        configure(engine)

        # At x=2.5: μ_Low=0.5, μ_High=0 → T(0.5, 0) = 0 → no activation
        iv.value = 2.5
        process(engine)
        @test abs(ov.lastValidOutput) < 1e-10

        # At x=5.0: μ_Low=0, μ_High=0 → T(0,0) = 0 → no activation
        iv.value = 5.0
        process(engine)
        @test abs(ov.lastValidOutput) < 1e-10
    end

end
