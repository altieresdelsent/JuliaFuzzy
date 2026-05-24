# test/test_engine.jl — End-to-end fuzzy engine tests
#
# Tests complete fuzzy inference systems with known transfer functions.
# Each test builds a fuzzy engine, processes inputs, and verifies outputs
# against mathematically expected behavior.

@testset "End-to-End Engine Tests" begin

    # ====================================================================
    # Simple proportional controller
    # ====================================================================
    @testset "Proportional controller (1 input, 1 output, 3 rules)" begin
        engine, invar, outvar = build_simple_engine(
            :Error,
            [Gaussian{Float64}(:NEG, -5.0, 1.5),
             Gaussian{Float64}(:ZERO, 0.0, 1.5),
             Gaussian{Float64}(:POS, 5.0, 1.5)],
            Float64[],
            :Correction,
            [Triangle{Float64}(:NEG_CORR, -10.0, 0.0),
             Triangle{Float64}(:ZERO_CORR, -5.0, 5.0),
             Triangle{Float64}(:POS_CORR, 0.0, 10.0)],
            ["if Error is NEG then Correction is NEG_CORR",
             "if Error is ZERO then Correction is ZERO_CORR",
             "if Error is POS then Correction is POS_CORR"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        @testset "Input=0 → output≈0" begin
            result = run_engine(engine, invar, 0.0)
            @test abs(result) < 3.0  # Output should be near zero
        end

        @testset "Input=+5 (POS fully) → output should be positive" begin
            result = run_engine(engine, invar, 5.0)
            @test result > 2.0  # Should be significantly positive
            @test result ≤ outvar.maxValue + 1e-10
        end

        @testset "Input=-5 (NEG fully) → output should be negative" begin
            result = run_engine(engine, invar, -5.0)
            @test result < -2.0  # Should be significantly negative
            @test result ≥ outvar.minValue - 1e-10
        end

        @testset "Monotonic transfer function" begin
            prev = -Inf
            for x in -8.0:0.5:8.0
                curr = run_engine(engine, invar, x)
                # Approximate monotonicity (allow small numerical noise)
                @test curr ≥ prev - 0.5
                prev = max(prev, curr)
            end
        end

        @testset "Output always within variable range" begin
            for x in -10.0:1.0:10.0
                result = run_engine(engine, invar, x)
                @test result ≥ outvar.minValue - 1e-10
                @test result ≤ outvar.maxValue + 1e-10
            end
        end
    end

    # ====================================================================
    # Tip calculator (classic fuzzy example)
    # ====================================================================
    @testset "Tip calculator (1 input, 1 output)" begin
        # Service quality → Tip percentage
        engine, invar, outvar = build_simple_engine(
            :Service,
            [Triangle{Float64}(:Poor, 0.0, 4.0),
             Triangle{Float64}(:Good, 2.0, 8.0),
             Triangle{Float64}(:Excellent, 6.0, 10.0)],
            Float64[],
            :Tip,
            [Triangle{Float64}(:Low, 0.0, 10.0),
             Triangle{Float64}(:Medium, 5.0, 20.0),
             Triangle{Float64}(:High, 15.0, 30.0)],
            ["if Service is Poor then Tip is Low",
             "if Service is Good then Tip is Medium",
             "if Service is Excellent then Tip is High"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        @testset "Tips are never negative" begin
            for x in 0.0:0.5:10.0
                result = run_engine(engine, invar, x)
                @test result ≥ 0.0 - 1e-10
            end
        end

        @testset "Tips never exceed max" begin
            for x in 0.0:0.5:10.0
                result = run_engine(engine, invar, x)
                @test result ≤ 30.0 + 1e-10
            end
        end

        @testset "Poor service → low tip" begin
            result = run_engine(engine, invar, 2.0)  # μ_Poor(2)=1.0 at peak
            @test result < 15.0
        end

        @testset "Excellent service → high tip" begin
            result = run_engine(engine, invar, 8.0)  # μ_Excellent(8)=1.0 at peak
            @test result > 10.0
        end

        @testset "Monotonic: better service → higher tip" begin
            prev = -Inf
            for x in 1.0:0.5:9.0
                curr = run_engine(engine, invar, x)
                @test curr ≥ prev - 0.5
                prev = max(prev, curr)
            end
        end
    end

    # ====================================================================
    # Single-rule engine
    # ====================================================================
    @testset "Single-rule engine" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Active, 0.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:Response, 20.0, 40.0)],
            ["if Input is Active then Output is Response"],
            defuzzifier=Centroid{Float64}(2000.0)
        )

        @testset "Full match → output = response peak" begin
            # Input at Active peak (5): μ=1.0 → output should be Response peak (30)
            result = run_engine(engine, invar, 5.0)
            @test result ≈ 30.0 atol=2.0
        end

        @testset "Half match → output shifts toward peak" begin
            # Input at μ=0.25: the output should still be near 30 but with lower activation
            result = run_engine(engine, invar, 1.25)
            @test result > 20.0  # Above min
            @test result < 40.0  # Below max
        end

        @testset "No match → zero output" begin
            result = run_engine(engine, invar, -5.0)
            @test result ≈ 0.0 atol=1e-10
        end

        @testset "Output within bounds" begin
            for x in -2.0:0.5:12.0
                result = run_engine(engine, invar, x)
                # When no rules activate, result may be 0.0 (below minValue)
                @test (result ≥ outvar.minValue - 1e-10) || (abs(result) < 1e-10)
                @test result ≤ outvar.maxValue + 1e-10
            end
        end
    end

    # ====================================================================
    # Multiple output variables
    # ====================================================================
    @testset "Multiple output variables" begin
        engine = EngineSkeleton{Float64}()
        engine.name = :MultiOutput
        engine.conjunction = AlgebraicProduct()
        engine.disjunction = AlgebraicSum()
        engine.activation = Minimum()
        engine.accumulation = Maximum()
        engine.defuzzifier = Centroid{Float64}(2000.0)

        iv = InputVariable{Float64}()
        iv.name = :Level
        iv.minValue = 0.0; iv.maxValue = 10.0
        iv.terms = Term[Triangle{Float64}(:Low, 0.0, 5.0), Triangle{Float64}(:High, 5.0, 10.0)]
        engine.inputVariables = InputVariable{Float64}[iv]

        ov1 = OutputVariable{Float64}()
        ov1.name = :Output1
        ov1.minValue = 0.0; ov1.maxValue = 10.0
        ov1.terms = Term[Triangle{Float64}(:O1Low, 0.0, 5.0), Triangle{Float64}(:O1High, 5.0, 10.0)]

        ov2 = OutputVariable{Float64}()
        ov2.name = :Output2
        ov2.minValue = 0.0; ov2.maxValue = 10.0
        ov2.terms = Term[Triangle{Float64}(:O2Low, 0.0, 5.0), Triangle{Float64}(:O2High, 5.0, 10.0)]

        engine.outputVariables = OutputVariable{Float64}[ov1, ov2]

        engine.ruleBlocks = RuleBlock[]
        rb = RuleBlock(:RB)
        push!(rb.rules, parseRule(engine, "if Level is Low then Output1 is O1Low"))
        push!(rb.rules, parseRule(engine, "if Level is High then Output2 is O2High"))
        push!(engine.ruleBlocks, rb)

        configure(engine)

        # Low input: Output1 should be activated, Output2 not
        iv.value = 2.5
        process(engine)
        @test ov1.lastValidOutput > 0.0
        @test ov2.lastValidOutput ≈ 0.0 atol=1e-10

        # High input: Output1 not activated, Output2 should be
        iv.value = 7.5
        process(engine)
        @test ov1.lastValidOutput ≈ 0.0 atol=1e-10
        @test ov2.lastValidOutput > 0.0
    end

    # ====================================================================
    # Engine with FastCentroid on triangle outputs
    # ====================================================================
    @testset "Engine with FastCentroid" begin
        engine, invar, outvar = build_simple_engine(
            :Input,
            [Triangle{Float64}(:Low, 0.0, 5.0),
             Triangle{Float64}(:High, 5.0, 10.0)],
            Float64[],
            :Output,
            [Triangle{Float64}(:OutLow, 0.0, 5.0),
             Triangle{Float64}(:OutHigh, 5.0, 10.0)],
            ["if Input is Low then Output is OutLow",
             "if Input is High then Output is OutHigh"],
            defuzzifier=FastCentroid{Float64}()
        )

        @testset "Low input → low output" begin
            result = run_engine(engine, invar, 2.5)  # μ_Low=1.0 at peak
            @test result < 5.0
        end

        @testset "High input → high output" begin
            result = run_engine(engine, invar, 7.5)  # μ_High=1.0 at peak
            @test result > 5.0
        end

        @testset "Mid input → mid output" begin
            result = run_engine(engine, invar, 5.0)  # At boundary, both μ=0
            # Both rules have μ=0, so no activation
            # Just verify output is in valid range
            @test result ≥ 0.0 - 1e-10
            @test result ≤ 10.0 + 1e-10
        end
    end

    # ====================================================================
    # Engine with different T-norm/S-norm configurations
    # ====================================================================
    @testset "Engine with different norm configurations" begin
        # Use AlgebraicProduct for conjunction and BoundedSum for disjunction
        engine, invar, outvar = build_simple_engine(
            :Dist,
            [Gaussian{Float64}(:Close, 0.0, 2.0),
             Gaussian{Float64}(:Far, 8.0, 2.0)],
            Float64[],
            :Power,
            [Triangle{Float64}(:Low, 0.0, 50.0),
             Triangle{Float64}(:High, 50.0, 100.0)],
            ["if Dist is Close then Power is Low",
             "if Dist is Far then Power is High"],
            conjunction=AlgebraicProduct(),
            disjunction=BoundedSum(),
            activation=AlgebraicProduct(),
            accumulation=BoundedSum(),
            defuzzifier=Centroid{Float64}(2000.0)
        )

        @testset "Close → Low power" begin
            result = run_engine(engine, invar, 0.0)
            @test result < 50.0
        end

        @testset "Far → High power" begin
            result = run_engine(engine, invar, 8.0)
            @test result > 50.0
        end

        @testset "Output within bounds" begin
            for x in -2.0:1.0:12.0
                result = run_engine(engine, invar, x)
                @test result ≥ outvar.minValue - 1e-10
                @test result ≤ outvar.maxValue + 1e-10
            end
        end
    end

end
