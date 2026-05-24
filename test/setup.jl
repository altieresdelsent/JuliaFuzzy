# test/setup.jl — Shared imports and utilities for JuliaFuzzy test suite

using JuliaFuzzy
using Test

# === Norms ===
using JuliaFuzzy.Norms: compute, TNorm, SNorm
using JuliaFuzzy.Norms.TNorms: Minimum, AlgebraicProduct, BoundedDifference,
    EinsteinProduct, HamacherProduct, DrasticProduct
using JuliaFuzzy.Norms.SNorms: Maximum, AlgebraicSum, BoundedSum,
    EinsteinSum, HamacherSum, NormalizedSum, DrasticSum

# === Terms ===
using JuliaFuzzy.Terms: membership, Triangle, Trapezoid, Gaussian, Sigmoid,
    Activated, Accumulated, Term,
    GaussianType_Normal, GaussianType_Left, GaussianType_Right

# === Defuzzifiers ===
using JuliaFuzzy.Defuzzifiers: Centroid, FastCentroid

# === Variables ===
using JuliaFuzzy.Variables: InputVariable, OutputVariable
using JuliaFuzzy.Variables: defuzzify as var_defuzzify

# === Rules ===
using JuliaFuzzy.Rules: Rule, RuleBlock, Antecedent, Consequent, Proposition, Operator, And, Or

# === Engine ===
using JuliaFuzzy: EngineSkeleton, parseRule, configure, firstConfiguration, process

# === Test utilities ===

"""
    fuzzy_centroid_analytical(xs, ys)

Compute the analytical centroid of a discrete fuzzy set using the standard formula:
C_x = Σ(y_i * x_i) / Σ(y_i)
This matches the Wikipedia centroid definition for fuzzy sets.
"""
function fuzzy_centroid_analytical(xs::Vector{Float64}, ys::Vector{Float64})
    @assert length(xs) == length(ys)
    numerator = sum(ys .* xs)
    denominator = sum(ys)
    if denominator < 1e-15
        return 0.0
    end
    return numerator / denominator
end

"""
    triangle_area(a, b, c, height)

Area of a triangle with vertices (a,0), (b,height), (c,0).
"""
function triangle_area(a::Float64, b::Float64, c::Float64, height::Float64=1.0)
    return 0.5 * abs(c - a) * height
end

"""
    triangle_centroid_x(a, b, c)

X-coordinate of the centroid of a triangle with vertices (a,0), (b,h), (c,0).
For an isosceles triangle, this equals b (the peak).
For a general triangle, it's (a + b + c) / 3.
"""
function triangle_centroid_x(a::Float64, b::Float64, c::Float64)
    return (a + b + c) / 3.0
end

"""
    truncated_triangle_centroid(a, b, c, activation)

Compute the centroid x-coordinate of a triangle truncated at activation level.
The truncated shape is the portion of the triangle below activation * height.
Returns the centroid of the truncated region.
"""
function truncated_triangle_centroid(a::Float64, b::Float64, c::Float64, activation::Float64)
    if activation >= 1.0 - 1e-12
        return triangle_centroid_x(a, b, c)
    end
    if activation <= 1e-12
        return b  # degenerate, just return peak
    end
    # The truncated shape is a trapezoid (or triangle if activation = height at one point)
    # For triangle with peak at b: left slope from (a,0) to (b,1), right slope from (b,1) to (c,0)
    # At activation level α, left intersection: x_left = a + α*(b-a)
    # At activation level α, right intersection: x_right = c - α*(c-b)
    x_left = a + activation * (b - a)
    x_right = c - activation * (c - b)
    # The truncated shape is a trapezoid with vertices (x_left, α), (x_right, α), (c,0), (a,0)
    # ...actually it's the area BELOW activation, which is a trapezoid:
    # vertices: (a,0), (x_left,α), (x_right,α), (c,0)
    # Centroid of trapezoid = weighted average of rectangle + two triangles
    # Simpler: compute as area above the cut subtracted from full triangle
    # Full triangle centroid = (a+b+c)/3
    # Upper small triangle: base from x_left to x_right at height α, peak at (b,1)
    # Upper triangle centroid = b (peak of small triangle, which is still at x=b)
    # Actually, the upper part is a smaller similar triangle with vertices (x_left,α), (b,1), (x_right,α)
    # Its centroid x = (x_left + b + x_right) / 3 = (a + α(b-a) + b + c - α(c-b)) / 3
    upper_centroid = (x_left + b + x_right) / 3.0
    area_full = triangle_area(a, b, c)
    area_upper = triangle_area(x_left, b, x_right, 1.0 - activation)
    area_lower = area_full - area_upper
    if area_lower < 1e-15
        return b
    end
    # Lower part centroid from area-weighted subtraction
    lower_centroid = (area_full * triangle_centroid_x(a, b, c) - area_upper * upper_centroid) / area_lower
    return lower_centroid
end

"""
    build_simple_engine(input_name, input_terms, input_values,
                        output_name, output_terms,
                        rules_strs;
                        conjunction=AlgebraicProduct(),
                        disjunction=AlgebraicSum(),
                        activation=Minimum(),
                        accumulation=Maximum(),
                        defuzzifier=Centroid{Float64}(2000.0))

Build a simple fuzzy engine with one input and one output variable.
Returns (engine, input_var, output_var).
"""
function build_simple_engine(input_name::Symbol, input_terms::Vector, input_values::Vector{Float64},
                              output_name::Symbol, output_terms::Vector,
                              rules_strs::Vector{String};
                              conjunction=AlgebraicProduct(),
                              disjunction=AlgebraicSum(),
                              activation=Minimum(),
                              accumulation=Maximum(),
                              defuzzifier=Centroid{Float64}(2000.0))
    engine = EngineSkeleton{Float64}()
    engine.name = Symbol("TestEngine_", input_name)
    engine.inputVariables = InputVariable{Float64}[]
    engine.outputVariables = OutputVariable{Float64}[]
    engine.ruleBlocks = RuleBlock[]
    engine.conjunction = conjunction
    engine.disjunction = disjunction
    engine.activation = activation
    engine.accumulation = accumulation
    engine.defuzzifier = defuzzifier

    # Input variable
    invar = InputVariable{Float64}()
    invar.name = input_name
    invar.terms = Term[input_terms...]
    # Compute range from terms
    mins = Float64[]
    maxs = Float64[]
    for t in input_terms
        if t isa Gaussian || t isa Sigmoid || t isa Triangle || t isa Trapezoid
            push!(mins, t.minValue)
            push!(maxs, t.maxValue)
        end
    end
    invar.minValue = isempty(mins) ? -10.0 : minimum(mins)
    invar.maxValue = isempty(maxs) ? 10.0 : maximum(maxs)
    push!(engine.inputVariables, invar)

    # Output variable
    outvar = OutputVariable{Float64}()
    outvar.name = output_name
    outvar.defuzzifier = defuzzifier
    outvar.terms = Term[output_terms...]
    mins = Float64[]
    maxs = Float64[]
    for t in output_terms
        if t isa Gaussian || t isa Sigmoid || t isa Triangle || t isa Trapezoid
            push!(mins, t.minValue)
            push!(maxs, t.maxValue)
        end
    end
    outvar.minValue = isempty(mins) ? -10.0 : minimum(mins)
    outvar.maxValue = isempty(maxs) ? 10.0 : maximum(maxs)
    push!(engine.outputVariables, outvar)

    # Rule block
    rb = RuleBlock(Symbol("RB_", input_name))
    for rs in rules_strs
        rule = parseRule(engine, rs)
        push!(rb.rules, rule)
    end
    push!(engine.ruleBlocks, rb)

    configure(engine)
    
    return (engine, invar, outvar)
end

"""
    run_engine(engine, input_var, input_value)

Set the input variable value, process the engine, and return the defuzzified output.
Returns the output value for the first output variable.
"""
function run_engine(engine, input_var, input_value::Float64)
    input_var.value = input_value
    process(engine)
    # Return the first output variable's lastValidOutput
    return engine.outputVariables[1].lastValidOutput
end

println("setup.jl loaded successfully")
