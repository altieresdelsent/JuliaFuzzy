module Norms
    #using Debug
    abstract type Norm end
    abstract type SNorm <: Norm end
    abstract type TNorm <: Norm end
    mutable struct DoesNotExistNorm <: Norm
    end

    isdefined(@__MODULE__, :SNorms) || include("s/SNorms.jl")
    isdefined(@__MODULE__, :TNorms) || include("t/TNorms.jl")
    if !isdefined(@__MODULE__, :compute)
    	include("s/compute.jl")
    	include("t/compute.jl")
    end
end
