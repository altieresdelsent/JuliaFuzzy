module Norms
    #using Debug
    abstract Norm
    abstract SNorm <: Norm
    abstract TNorm <: Norm
    type DoesNotExistNorm <: Norm
    end

    isdefined(:SNorms) || include("s/SNorms.jl")
    isdefined(:TNorms) || include("t/TNorms.jl")
    if !isdefined(:compute)
    	include("s/compute.jl")
    	include("t/compute.jl")
    end
end
