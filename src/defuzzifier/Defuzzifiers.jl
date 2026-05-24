module Defuzzifiers
    #using Debug

    abstract type Defuzzifier end
    abstract type IntegralDefuzzifier <: Defuzzifier end

    mutable struct Bisector{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    mutable struct Centroid{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    mutable struct FastCentroid{T <: AbstractFloat} <: Defuzzifier
    end

    mutable struct LargestOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    mutable struct MeansOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    mutable struct SmallestOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    mutable struct Tsukamoto{T <: AbstractFloat} <: Defuzzifier
    end

    mutable struct WeightedAverage{T <: AbstractFloat} <: IntegralDefuzzifier
    end

    mutable struct WeightedSum{T <: AbstractFloat} <: IntegralDefuzzifier
    end

    include("defuzzify.jl")

end
