# test/test_defuzzifiers.jl — Defuzzifier correctness tests
#
# Tests Centroid and FastCentroid defuzzifiers against known analytical results.
# - Centroid: numerical integration of fuzzy output
# - FastCentroid: geometric calculation for triangular terms
# - Cross-validation: FastCentroid ≈ Centroid for triangle outputs
#
# Tests are fuzzy-logic agnostic: they verify that defuzzification produces
# the mathematically correct centroid per https://en.wikipedia.org/wiki/Centroid

@testset "Defuzzifiers" begin

    # === Helper: build output variable with a single activated triangle ===
    function make_output_with_single_triangle(tri::Triangle{Float64}, degree::Float64, minv::Float64, maxv::Float64)
        out = OutputVariable{Float64}()
        out.name = :test_out
        out.defuzzifier = Centroid{Float64}(2000.0)
        out.minValue = minv
        out.maxValue = maxv
        out.terms = Term[tri]
        out.fuzzyOutput = Accumulated{Float64}()
        out.fuzzyOutput.accumulation = Maximum()
        out.fuzzyOutput.minimum = minv
        out.fuzzyOutput.maximum = maxv
        push!(out.fuzzyOutput.terms, Activated{Float64, Triangle{Float64}}(tri, degree, Minimum()))
        return out
    end

    function make_output_with_two_triangles(tri1::Triangle{Float64}, deg1::Float64,
                                             tri2::Triangle{Float64}, deg2::Float64,
                                             minv::Float64, maxv::Float64)
        out = OutputVariable{Float64}()
        out.name = :test_out
        out.defuzzifier = Centroid{Float64}(2000.0)
        out.minValue = minv
        out.maxValue = maxv
        out.terms = Term[tri1, tri2]
        out.fuzzyOutput = Accumulated{Float64}()
        out.fuzzyOutput.accumulation = Maximum()
        out.fuzzyOutput.minimum = minv
        out.fuzzyOutput.maximum = maxv
        push!(out.fuzzyOutput.terms, Activated{Float64, Triangle{Float64}}(tri1, deg1, Minimum()))
        push!(out.fuzzyOutput.terms, Activated{Float64, Triangle{Float64}}(tri2, deg2, Minimum()))
        return out
    end

    # ====================================================================
    # Centroid Tests
    # ====================================================================
    @testset "Centroid (numerical integration)" begin

        @testset "Single triangle, full activation → centroid at vertexB" begin
            # Triangle from (0,0) through (1,1) to (2,0) — peak at x=1
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            # Centroid of isosceles triangle is at the peak
            @test result ≈ 1.0 atol=1e-3
        end

        @testset "Triangle shifted right" begin
            # Triangle from (2,0) through (4,1) to (6,0) — peak at x=4
            tri = Triangle{Float64}(:tri, 2.0, 6.0)
            out = make_output_with_single_triangle(tri, 1.0, 0.0, 8.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 4.0 atol=1e-3
        end

        @testset "Triangle shifted left" begin
            # Triangle from (-3,0) through (-1,1) to (1,0) — peak at x=-1
            tri = Triangle{Float64}(:tri, -3.0, 1.0)
            out = make_output_with_single_triangle(tri, 1.0, -5.0, 3.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ -1.0 atol=1e-3
        end

        @testset "Triangle with partial activation (degree=0.5)" begin
            # Triangle (0,0)-(1,1)-(2,0), activated at 0.5
            # The truncated shape is a trapezoid. Centroid shifts toward the wider base.
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 0.5, -1.0, 3.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            # For an isosceles triangle truncated at 0.5:
            # x_left = 0 + 0.5*(1-0) = 0.5
            # x_right = 2 - 0.5*(2-1) = 1.5
            # The shape is a trapezoid from (0.5,0.5) to (1.5,0.5) plus the base from (0,0) to (2,0)
            # Centroid of lower trapezoid = analytically computable
            expected = truncated_triangle_centroid(0.0, 1.0, 2.0, 0.5)
            @test result ≈ expected atol=1e-2
        end

        @testset "Triangle with low activation (degree=0.1)" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 0.1, -1.0, 3.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            expected = truncated_triangle_centroid(0.0, 1.0, 2.0, 0.1)
            @test result ≈ expected atol=1e-2
        end

        @testset "Two non-overlapping triangles" begin
            # Triangle 1: (0,0)-(1,1)-(2,0), activated 1.0
            # Triangle 2: (4,0)-(5,1)-(6,0), activated 0.5
            tri1 = Triangle{Float64}(:t1, 0.0, 2.0)
            tri2 = Triangle{Float64}(:t2, 4.0, 6.0)
            out = make_output_with_two_triangles(tri1, 1.0, tri2, 0.5, -2.0, 8.0)
            
            result = JuliaFuzzy.Variables.defuzzify(out)
            # Area-weighted centroid:
            # Area of tri1 = 1.0 (base=2, height=1)
            # Area of tri2 (truncated at 0.5) = trapezoid...
            # tri2 full area = 1.0, truncated area = (1 - (1-0.5)²) * 1.0 = 0.75
            # Actually simpler: centroid of full tri1 = 1.0, area = 1.0
            # truncated tri2: x_left = 4.5, x_right = 5.5, centroid ≈ 5.0, area ≈ 0.75
            # weighted: (1.0*1.0 + 0.75*5.0) / (1.0 + 0.75) = 4.75/1.75 ≈ 2.714
            area1 = triangle_area(0.0, 1.0, 2.0)  # = 1.0
            centroid1 = triangle_centroid_x(0.0, 1.0, 2.0)  # = 1.0
            area2 = triangle_area(4.0, 5.0, 6.0)  # = 1.0
            # Truncated area: subtract top small triangle
            small_area2 = triangle_area(4.5, 5.0, 5.5, 0.5)  # = 0.5 * 1.0 * 0.5 = 0.25
            truncated_area2 = area2 - small_area2  # = 0.75
            small_centroid2 = triangle_centroid_x(4.5, 5.0, 5.5)  # = 5.0
            centroid2 = (area2 * triangle_centroid_x(4.0, 5.0, 6.0) - small_area2 * small_centroid2) / truncated_area2
            expected = (area1 * centroid1 + truncated_area2 * centroid2) / (area1 + truncated_area2)
            
            @test result ≈ expected atol=5e-2
        end

        @testset "Two overlapping triangles with Maximum accumulation" begin
            # Triangle 1: (0,0)-(2,1)-(4,0) — peak at 2
            # Triangle 2: (1,0)-(3,1)-(5,0) — peak at 3
            # They overlap in [1,4]; at maximum, the envelope isn't a simple triangle
            tri1 = Triangle{Float64}(:t1, 0.0, 4.0)
            tri2 = Triangle{Float64}(:t2, 1.0, 5.0)
            out = make_output_with_two_triangles(tri1, 1.0, tri2, 1.0, -2.0, 7.0)

            result = JuliaFuzzy.Variables.defuzzify(out)
            # The centroid should be between the two peaks (2 and 3)
            @test result > 2.0
            @test result < 3.0
            # With symmetric overlap, should be ≈ 2.5
            @test result ≈ 2.5 atol=0.3
        end

        @testset "Centroid resolution affects accuracy" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out_low = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            out_low.defuzzifier = Centroid{Float64}(10.0)  # Low resolution
            
            out_high = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            out_high.defuzzifier = Centroid{Float64}(2000.0)  # High resolution

            # High resolution should be closer to 1.0
            @test abs(JuliaFuzzy.Variables.defuzzify(out_high) - 1.0) ≤
                  abs(JuliaFuzzy.Variables.defuzzify(out_low) - 1.0) + 1e-10
        end

        @testset "Zero activation → zero output" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 0.0, -1.0, 3.0)
            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 0.0 atol=1e-10
        end

    end

    # ====================================================================
    # FastCentroid Tests
    # ====================================================================
    @testset "FastCentroid (geometric, triangles only)" begin

        @testset "Single triangle → centroid at vertexB" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 1.0 atol=1e-3
        end

        @testset "Single triangle shifted" begin
            tri = Triangle{Float64}(:tri, 2.0, 6.0)
            out = make_output_with_single_triangle(tri, 1.0, 0.0, 8.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 4.0 atol=1e-3
        end

        @testset "Single triangle with partial activation" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 0.5, -1.0, 3.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            expected = truncated_triangle_centroid(0.0, 1.0, 2.0, 0.5)
            @test result ≈ expected atol=0.2
        end

        @testset "Two non-overlapping triangles" begin
            tri1 = Triangle{Float64}(:t1, 0.0, 2.0)
            tri2 = Triangle{Float64}(:t2, 4.0, 6.0)
            out = make_output_with_two_triangles(tri1, 1.0, tri2, 1.0, -2.0, 8.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            # Both fully activated, equal area → centroid = avg of peaks
            expected = (1.0 + 5.0) / 2.0  # = 3.0
            @test result ≈ expected atol=1e-3
        end

        @testset "Two overlapping triangles" begin
            tri1 = Triangle{Float64}(:t1, 0.0, 4.0)
            tri2 = Triangle{Float64}(:t2, 1.0, 5.0)
            out = make_output_with_two_triangles(tri1, 1.0, tri2, 1.0, -2.0, 7.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result > 2.0
            @test result < 3.0
            @test result ≈ 2.5 atol=0.3
        end

        @testset "Zero activation → returns 0.0" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 0.0, -1.0, 3.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 0.0 atol=1e-10
        end

        @testset "Very low activation" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            out = make_output_with_single_triangle(tri, 1e-6, -1.0, 3.0)
            out.defuzzifier = FastCentroid{Float64}()

            result = JuliaFuzzy.Variables.defuzzify(out)
            @test result ≈ 0.0 atol=1e-10
        end

    end

    # ====================================================================
    # Cross-validation: FastCentroid vs Centroid
    # ====================================================================
    @testset "FastCentroid ≈ Centroid (cross-validation)" begin

        @testset "Identical single triangle" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            
            out_cent = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            out_fast = make_output_with_single_triangle(tri, 1.0, -1.0, 3.0)
            out_fast.defuzzifier = FastCentroid{Float64}()

            result_cent = JuliaFuzzy.Variables.defuzzify(out_cent)
            result_fast = JuliaFuzzy.Variables.defuzzify(out_fast)
            
            @test result_fast ≈ result_cent atol=0.01
        end

        @testset "Identical triangles with partial activation" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            
            out_cent = make_output_with_single_triangle(tri, 0.6, -1.0, 3.0)
            out_fast = make_output_with_single_triangle(tri, 0.6, -1.0, 3.0)
            out_fast.defuzzifier = FastCentroid{Float64}()

            result_cent = JuliaFuzzy.Variables.defuzzify(out_cent)
            result_fast = JuliaFuzzy.Variables.defuzzify(out_fast)
            
            @test result_fast ≈ result_cent atol=0.1
        end

        @testset "Identical two non-overlapping triangles" begin
            tri1 = Triangle{Float64}(:t1, 0.0, 2.0)
            tri2 = Triangle{Float64}(:t2, 4.0, 6.0)
            
            out_cent = make_output_with_two_triangles(tri1, 1.0, tri2, 0.5, -2.0, 8.0)
            out_fast = make_output_with_two_triangles(tri1, 1.0, tri2, 0.5, -2.0, 8.0)
            out_fast.defuzzifier = FastCentroid{Float64}()

            result_cent = JuliaFuzzy.Variables.defuzzify(out_cent)
            result_fast = JuliaFuzzy.Variables.defuzzify(out_fast)
            
            @test result_fast ≈ result_cent atol=0.1
        end

        @testset "Shifted triangle — FastCentroid == Centroid" begin
            for shift in [-5.0, -2.0, 0.0, 3.0, 7.0]
                tri = Triangle{Float64}(Symbol(:tri_, shift), shift, shift + 2.0)

                out_cent = make_output_with_single_triangle(tri, 1.0, shift - 2.0, shift + 4.0)
                out_fast = make_output_with_single_triangle(tri, 1.0, shift - 2.0, shift + 4.0)
                out_fast.defuzzifier = FastCentroid{Float64}()

                result_cent = JuliaFuzzy.Variables.defuzzify(out_cent)
                result_fast = JuliaFuzzy.Variables.defuzzify(out_fast)

                @test result_fast ≈ result_cent atol=0.02
            end
        end

    end

    # ====================================================================
    # Wikipedia Centroid Formula Verification
    # ====================================================================
    @testset "Centroid formula: C_x = Σ(μ(x) · x) / Σ(μ(x))" begin
        
        @testset "Matches discrete numerical integration" begin
            tri = Triangle{Float64}(:tri, 0.0, 2.0)
            
            # Sample the membership at discrete points
            xs = collect(0.0:0.01:2.0)
            ys = [membership(tri, x) for x in xs]
            
            discrete_centroid = fuzzy_centroid_analytical(xs, ys)
            # The discrete sampled centroid of a triangle should equal its vertexB
            @test discrete_centroid ≈ 1.0 atol=1e-3
        end

        @testset "Triangle with activation" begin
            tri = Triangle{Float64}(:tri, -1.0, 3.0)  # peak at 1.0
            act = Activated{Float64, Triangle{Float64}}(tri, 1.0, Minimum())

            xs = collect(-1.0:0.01:3.0)
            ys = [membership(act, x) for x in xs]
            
            discrete_centroid = fuzzy_centroid_analytical(xs, ys)
            @test discrete_centroid ≈ 1.0 atol=1e-3
        end

        @testset "Two triangles envelope centroid" begin
            tri1 = Triangle{Float64}(:t1, 0.0, 4.0)  # peak at 2
            tri2 = Triangle{Float64}(:t2, 1.0, 5.0)  # peak at 3

            xs = collect(-1.0:0.01:6.0)
            ys = [max(membership(tri1, x), membership(tri2, x)) for x in xs]

            discrete_centroid = fuzzy_centroid_analytical(xs, ys)
            # Should be between 2 and 3
            @test discrete_centroid > 2.0
            @test discrete_centroid < 3.0
        end

    end

end
