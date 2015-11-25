module Defuzzifiers
    #using Debug

    abstract Defuzzifier
    abstract IntegralDefuzzifier <: Defuzzifier

    type Bisector{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    type Centroid{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    type FastCentroid{T <: AbstractFloat} <: Defuzzifier
    end

    type LargestOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    type MeansOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    type SmallestOfMaximum{T <: AbstractFloat} <: IntegralDefuzzifier
        resolution::T
    end

    type Tsukamoto{T <: AbstractFloat} <: Defuzzifier
    end

    type WeightedAverage{T <: AbstractFloat} <: IntegralDefuzzifier
    end

    type WeightedSum{T <: AbstractFloat} <: IntegralDefuzzifier
    end

    include("defuzzify.jl")

end
