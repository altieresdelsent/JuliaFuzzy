    # types.jl

#
module LinearAlgebra

    export LinearFunc, FastSolution, solve, solveFast

    isdefined(:LinearFunc) || include("LinearFunc.jl")
    isdefined(:FastSolution) || include("FastSolution.jl")
    isdefined(:solve) || include("solve.jl")
    isdefined(:solveFast) || include("solveFast.jl")
end


