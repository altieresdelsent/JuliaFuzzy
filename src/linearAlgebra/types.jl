    # types.jl

#
module LinearAlgebra

    export LinearFunc, FastSolution, solve, solveFast

    isdefined(:LinearFunc) || include("types/LinearFunc.jl")
    isdefined(:FastSolution) || include("types/FastSolution.jl")
    isdefined(:solve) || include("types/solve.jl")
    isdefined(:solveFast) || include("types/solveFast.jl")
end


