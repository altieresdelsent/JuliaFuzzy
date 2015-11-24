module Defuzzifiers
    #using Debug 
    
    abstract Defuzzifier
    abstract IntegralDefuzzifier <: Defuzzifier

    type Bisector {T <: FloatingPoint} <: IntegralDefuzzifier
        resolution::T
    end

    type Centroid {T <: FloatingPoint} <: IntegralDefuzzifier
        resolution::T
    end

    type FastCentroid {T <: FloatingPoint} <: Defuzzifier
    end

    type LargestOfMaximum {T <: FloatingPoint} <: IntegralDefuzzifier
        resolution::T
    end

    type MeansOfMaximum {T <: FloatingPoint} <: IntegralDefuzzifier
        resolution::T
    end

    type SmallestOfMaximum {T <: FloatingPoint} <: IntegralDefuzzifier
        resolution::T
    end

    type Tsukamoto {T <: FloatingPoint} <: Defuzzifier
    end

    type WeightedAverage {T <: FloatingPoint} <: IntegralDefuzzifier
    end

    type WeightedSum {T <: FloatingPoint} <: IntegralDefuzzifier
    end

    include("defuzzify.jl")

end
