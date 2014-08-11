module Norms
    abstract Norm
    abstract SNorm <: Norm
    abstract TNorm <: Norm
    type DoesNotExistNorm <: Norm
    end

    include("s/SNorms.jl")
    include("t/TNorms.jl")
    include("s/compute.jl")
    include("t/compute.jl")
end;
