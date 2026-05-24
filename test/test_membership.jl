# test/test_membership.jl — Membership function mathematical correctness tests
#
# Tests all term types for correct μ(x) evaluation:
# - Triangle: μ(A)=0, μ(B)=1, μ(C)=0, linear interpolation
# - Trapezoid: μ(A)=0, μ(B)=1, μ(C)=1, μ(D)=0
# - Gaussian: μ(mean)=1, μ(mean±σ)=exp(-0.5)
# - Sigmoid: μ(inflection)=0.5, monotonic, asymptotes
# - Activated: μ = T(μ_term(x), degree)
# - Accumulated: μ = S(μ₁, S(μ₂, ...))

@testset "Membership Functions" begin

    # === Triangle membership ===
    @testset "Triangle" begin
        # Triangle with name, vertexA, vertexC (vertexB is midpoint)
        tri = Triangle{Float64}(:test, 0.0, 2.0)

        @testset "Vertex values" begin
            # μ(vertexA) = 0
            @test membership(tri, 0.0) ≈ 0.0 atol=1e-15
            # μ(vertexB) = 1.0 (midpoint, peak)
            @test membership(tri, 1.0) ≈ 1.0 atol=1e-15
            # μ(vertexC) = 0
            @test membership(tri, 2.0) ≈ 0.0 atol=1e-15
        end

        @testset "Linear interpolation" begin
            # Left slope: from (0,0) to (1,1) — linear
            @test membership(tri, 0.0) ≈ 0.0 atol=1e-15
            @test membership(tri, 0.25) ≈ 0.25 atol=1e-12
            @test membership(tri, 0.5) ≈ 0.5 atol=1e-12
            @test membership(tri, 0.75) ≈ 0.75 atol=1e-12

            # Right slope: from (1,1) to (2,0) — linear
            @test membership(tri, 1.25) ≈ 0.75 atol=1e-12
            @test membership(tri, 1.5) ≈ 0.5 atol=1e-12
            @test membership(tri, 1.75) ≈ 0.25 atol=1e-12
            @test membership(tri, 2.0) ≈ 0.0 atol=1e-15
        end

        @testset "Out of range" begin
            @test membership(tri, -1.0) ≈ 0.0 atol=1e-15
            @test membership(tri, 3.0) ≈ 0.0 atol=1e-15
            @test membership(tri, -100.0) ≈ 0.0 atol=1e-15
            @test membership(tri, 100.0) ≈ 0.0 atol=1e-15
        end

        @testset "Range check: all values ∈ [0,1]" begin
            for x in -1.0:0.1:3.0
                mu = membership(tri, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end

        @testset "Asymmetric triangle" begin
            # Triangle with peak at 0.75 in range [0, 2]
            asym = Triangle{Float64}(:asym, 0.0, 2.0)
            # vertexB = (0+2)/2 = 1.0 (always midpoint for current constructor)
            # Let's test a triangle where the result is determined by the points
            # Triangle(-1, 1, 3) — A=-1, C=3, B=1 (midpoint, but not center geometrically)
            asym2 = Triangle{Float64}(:asym2, -1.0, 3.0)
            # B = (-1+3)/2 = 1.0 — this is always midpoint for default constructor
            @test membership(asym2, -1.0) ≈ 0.0
            @test membership(asym2, 1.0) ≈ 1.0
            @test membership(asym2, 3.0) ≈ 0.0
            @test membership(asym2, 0.0) ≈ 0.5
            @test membership(asym2, 2.0) ≈ 0.5
        end

        @testset "Triangle with custom height" begin
            tri_half = Triangle{Float64}(:half, 0.0, 2.0, 0.5)
            @test membership(tri_half, 0.0) ≈ 0.0
            @test membership(tri_half, 1.0) ≈ 0.5
            @test membership(tri_half, 2.0) ≈ 0.0
            @test membership(tri_half, 0.5) ≈ 0.25 atol=1e-12
            @test membership(tri_half, 1.5) ≈ 0.25 atol=1e-12
        end
    end

    # === Trapezoid membership ===
    @testset "Trapezoid" begin
        # Trapezoid with vertices A=0, B=1, C=3, D=4
        trap = Trapezoid{Float64}(:test, 0.0, 1.0, 3.0, 4.0)

        @testset "Vertex values" begin
            @test membership(trap, 0.0) ≈ 0.0 atol=1e-15  # A
            @test membership(trap, 1.0) ≈ 1.0 atol=1e-15  # B
            @test membership(trap, 3.0) ≈ 1.0 atol=1e-15  # C
            @test membership(trap, 4.0) ≈ 0.0 atol=1e-15  # D
        end

        @testset "Ramp up (A→B)" begin
            @test membership(trap, 0.25) ≈ 0.25 atol=1e-12
            @test membership(trap, 0.5) ≈ 0.5 atol=1e-12
            @test membership(trap, 0.75) ≈ 0.75 atol=1e-12
        end

        @testset "Plateau (B→C)" begin
            @test membership(trap, 1.5) ≈ 1.0 atol=1e-15
            @test membership(trap, 2.0) ≈ 1.0 atol=1e-15
            @test membership(trap, 2.5) ≈ 1.0 atol=1e-15
        end

        @testset "Ramp down (C→D)" begin
            @test membership(trap, 3.25) ≈ 0.75 atol=1e-12
            @test membership(trap, 3.5) ≈ 0.5 atol=1e-12
            @test membership(trap, 3.75) ≈ 0.25 atol=1e-12
        end

        @testset "Out of range" begin
            @test membership(trap, -1.0) ≈ 0.0 atol=1e-15
            @test membership(trap, 5.0) ≈ 0.0 atol=1e-15
        end

        @testset "Range check" begin
            for x in -1.0:0.2:5.0
                mu = membership(trap, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end
    end

    # === Gaussian membership ===
    @testset "Gaussian" begin
        gauss = Gaussian{Float64}(:test, 0.0, 1.0)  # mean=0, σ=1

        @testset "Peak at mean" begin
            @test membership(gauss, 0.0) ≈ 1.0 atol=1e-15
        end

        @testset "Standard deviation points" begin
            # μ(mean ± σ) = exp(-0.5) ≈ 0.60653
            expected_sigma = exp(-0.5)
            @test membership(gauss, 1.0) ≈ expected_sigma atol=1e-6
            @test membership(gauss, -1.0) ≈ expected_sigma atol=1e-6
        end

        @testset "Symmetry" begin
            for x in 0.0:0.5:5.0
                @test membership(gauss, x) ≈ membership(gauss, -x) atol=1e-12
            end
        end

        @testset "Monotonic decreasing from mean" begin
            prev = membership(gauss, 0.0)
            for x in 0.5:0.5:5.0
                curr = membership(gauss, x)
                @test curr ≤ prev + 1e-15
                prev = curr
            end
        end

        @testset "Range check" begin
            for x in -10.0:0.5:10.0
                mu = membership(gauss, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end

        @testset "Custom σ and mean" begin
            g2 = Gaussian{Float64}(:g2, 2.0, 0.5)
            @test membership(g2, 2.0) ≈ 1.0
            @test membership(g2, 2.5) ≈ exp(-0.5) atol=1e-6
            @test membership(g2, 1.5) ≈ exp(-0.5) atol=1e-6
        end

        @testset "Custom height" begin
            g3 = Gaussian{Float64}(:g3, 0.0, 1.0, GaussianType_Normal, 0.5)
            @test membership(g3, 0.0) ≈ 0.5 atol=1e-12
        end
    end

    # === Sigmoid membership ===
    @testset "Sigmoid" begin
        sig = Sigmoid{Float64}(:test, 2.0, 0.0)  # slope=2, inflection=0

        @testset "Inflection point" begin
            # μ(inflection) = height / 2 = 0.5
            @test membership(sig, 0.0) ≈ 0.5 atol=1e-12
        end

        @testset "Monotonic increasing" begin
            prev = -Inf
            for x in -5.0:0.5:5.0
                curr = membership(sig, x)
                @test curr ≥ prev - 1e-15
                prev = curr
            end
        end

        @testset "Asymptotic behavior" begin
            # Far left should approach 0
            @test membership(sig, -10.0) < 1e-8
            # Far right should approach 1
            @test membership(sig, 10.0) > 1.0 - 1e-8
        end

        @testset "Range check" begin
            for x in -20.0:1.0:20.0
                mu = membership(sig, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end

        @testset "Custom slope" begin
            sig_steep = Sigmoid{Float64}(:steep, 10.0, 0.0)
            @test membership(sig_steep, 0.0) ≈ 0.5 atol=1e-12
            @test membership(sig_steep, 0.5) > 0.99
            @test membership(sig_steep, -0.5) < 0.01
        end
    end

    # === Activated membership (term with activation degree) ===
    @testset "Activated (term + degree + T-norm)" begin
        tri = Triangle{Float64}(:tri, 0.0, 2.0)
        tri_half = Triangle{Float64}(:tri_half, 0.0, 2.0, 0.5)

        @testset "Minimum activation (standard)" begin
            # Activated with Minimum T-norm: μ(x) = min(μ_term(x), degree)
            act = Activated{Float64, Triangle{Float64}}(tri, 0.6, Minimum())

            # At peak (μ=1.0): result = min(1.0, 0.6) = 0.6
            @test membership(act, 1.0) ≈ 0.6 atol=1e-12
            # At half (μ=0.5): result = min(0.5, 0.6) = 0.5
            @test membership(act, 0.5) ≈ 0.5 atol=1e-12
            # At edge (μ=0.2): result = min(0.2, 0.6) = 0.2
            @test membership(act, 0.2) ≈ 0.2 atol=1e-12
            # Out of range (μ=0.0): result = 0.0
            @test membership(act, -1.0) ≈ 0.0 atol=1e-15
        end

        @testset "AlgebraicProduct activation" begin
            # Activated with Product T-norm: μ(x) = μ_term(x) * degree
            act = Activated{Float64, Triangle{Float64}}(tri, 0.6, AlgebraicProduct())

            @test membership(act, 1.0) ≈ 0.6 atol=1e-12  # 1.0 * 0.6
            @test membership(act, 0.5) ≈ 0.3 atol=1e-12  # 0.5 * 0.6
            @test membership(act, 0.0) ≈ 0.0 atol=1e-15
        end

        @testset "Degree = 1.0 → same as original term" begin
            act = Activated{Float64, Triangle{Float64}}(tri, 1.0, Minimum())
            for x in -0.5:0.25:2.5
                @test membership(act, x) ≈ membership(tri, x) atol=1e-12
            end
        end

        @testset "Degree = 0.0 → always 0" begin
            act = Activated{Float64, Triangle{Float64}}(tri, 0.0, Minimum())
            for x in -1.0:0.5:3.0
                @test membership(act, x) ≈ 0.0 atol=1e-15
            end
        end
    end

    # === Accumulated membership (multiple activated terms) ===
    @testset "Accumulated (S-norm aggregation)" begin
        tri1 = Triangle{Float64}(:t1, 0.0, 2.0)
        tri2 = Triangle{Float64}(:t2, 3.0, 5.0)

        @testset "Single activated term" begin
            acc = Accumulated{Float64}()
            acc.accumulation = Maximum()
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri1, 0.8, Minimum()))

            # Should equal the activated term's membership
            @test membership(acc, 1.0) ≈ 0.8 atol=1e-12
            @test membership(acc, 0.5) ≈ 0.5 atol=1e-12
            @test membership(acc, -1.0) ≈ 0.0 atol=1e-15
        end

        @testset "Two non-overlapping terms with Maximum accumulation" begin
            acc = Accumulated{Float64}()
            acc.accumulation = Maximum()
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri1, 0.6, Minimum()))
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri2, 0.8, Minimum()))

            # In tri1 region: max(0.6*μ_tri1, 0)
            @test membership(acc, 1.0) ≈ 0.6 atol=1e-12
            # In tri2 region: max(0, 0.8*μ_tri2)
            @test membership(acc, 4.0) ≈ 0.8 atol=1e-12
            # Between terms: both 0
            @test membership(acc, 2.5) ≈ 0.0 atol=1e-15
        end

        @testset "Accumulation with AlgebraicSum" begin
            acc = Accumulated{Float64}()
            acc.accumulation = AlgebraicSum()
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri1, 0.5, Minimum()))
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri2, 0.5, Minimum()))

            # In tri1 peak area (x=1.0): μ₁=0.5, μ₂=0 → S(0.5, 0) = 0.5
            @test membership(acc, 1.0) ≈ 0.5 atol=1e-12
            # In tri2 peak area (x=4.0): μ₁=0, μ₂=0.5 → S(0, 0.5) = 0.5
            @test membership(acc, 4.0) ≈ 0.5 atol=1e-12
        end

        @testset "Range check: accumulated membership ∈ [0,1]" begin
            acc = Accumulated{Float64}()
            acc.accumulation = Maximum()
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri1, 1.0, Minimum()))
            push!(acc.terms, Activated{Float64, Triangle{Float64}}(tri2, 1.0, Minimum()))

            for x in -1.0:0.2:6.0
                mu = membership(acc, x)
                @test mu ≥ 0.0 - 1e-15
                @test mu ≤ 1.0 + 1e-15
            end
        end
    end

end
