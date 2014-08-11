include("fastExp.jl")
function benchmarckExp()
    fast::Float64 = 0.0
    c = rand() * -7
    fast = fast + fastExp(c);
    fast = fast + exp(c);
end
