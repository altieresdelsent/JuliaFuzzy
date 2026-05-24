# test/runtests.jl — Entry point for JuliaFuzzy test suite
# Run with: julia --project=. test/runtests.jl

using Test

println("="^60)
println("  JuliaFuzzy Test Suite")
println("="^60)
println()

include("setup.jl")

@testset "JuliaFuzzy — Complete Test Suite" begin
    include("test_tnorms.jl")
    include("test_snorms.jl")
    include("test_membership.jl")
    include("test_defuzzifiers.jl")
    include("test_rules.jl")
    include("test_activation.jl")
    include("test_engine.jl")
    include("test_invariants.jl")
    include("test_edge_cases.jl")
end

println()
println("="^60)
println("  All tests completed")
println("="^60)
