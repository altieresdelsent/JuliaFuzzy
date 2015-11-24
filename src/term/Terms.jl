module Terms
    #using Debug

    using ..Norms.SNorm
    using ..Norms.TNorm
    abstract Term

    type Activated{T <: AbstractFloat, B <: Term} <: Term
        term::B
        degree::T
        activation::TNorm
    end

    type Accumulated{T <: AbstractFloat} <: Term
        terms::Array{Activated,1}
        minimum::T
        maximum::T
        accumulation::SNorm
        function Accumulated()
            acc = new()
            acc.terms = Array(Activated,0)
            acc.minimum = prevfloat(typemax(T))
            acc.maximum = prevfloat(typemin(T))
            return acc
        end
    end


    type Bell{T <: AbstractFloat, B <: Term} <: Term
        terms::Array{B,1}
        center::T
        width::T
        slope::T
        acumulation::SNorm
    end

    type Constant{T <: AbstractFloat} <: Term
        value::T
    end

    type Discrete{T <: AbstractFloat} <: Term
        x::Array{T,1}
        y::Array{T,1}
    end

    type functionTerm <: Term
    end
    const GaussianType_Left = -1
    const GaussianType_Normal = 0
    const GaussianType_Right = 1

    immutable Gaussian{T <: AbstractFloat} <: Term
        name::Symbol
        mean::T
        standardDeviation::T
        height::T
        maxValue::T
        minValue::T
        gaussType::Int64
        function Gaussian(name,mean,standardDeviation,typeG=GaussianType_Normal,height=1.0)
            minValue = mean-(5*standardDeviation)
            maxValue = mean+(5*standardDeviation)
            return new(name,mean,standardDeviation,height,maxValue,minValue,typeG)
        end
    end
    immutable Sigmoid{T <: AbstractFloat} <: Term
        name::Symbol
        slope::T
        inflection::T
        height::T
        maxValue::T
        minValue::T
        function Sigmoid(name,slope,inflection,height=1.0)
            minValue = inflection-(6*slope)
            maxValue = inflection+(6*slope)
            return new(name,slope,inflection,height,maxValue,minValue)
        end
    end

    immutable GaussianProduct{T <: AbstractFloat} <: Term
        meanA
        standardDeviationA
        meanB
        standardDeviationB
    end
    immutable Trapezoid{T <: AbstractFloat} <: Term
        name::Symbol
        vertexA::T
        vertexB::T
        vertexC::T
        vertexD::T
        height::T
        maxValue::T
        minValue::T
        function Trapezoid(name,a,b,c,d,height=1.0)
            new(name,a,b,c,d,height,a,d)
        end
    end
    immutable Triangle{T <: AbstractFloat} <: Term
        name::Symbol
        vertexA::T
        vertexC::T
        vertexB::T
        height::T
        maxValue::T
        minValue::T
        range::T
        tan::T
        intersectionPoint::Array{T,1}
        innerArea::T
        innerCenter::T
        function Triangle(name,a,c,height=1.0)
            maxValue = max(a,c)
            minValue = min(a,c)
            range = maxValue - minValue
            tan = range / (2*height)
            return new(name,minValue,maxValue,((a+c)/2),height,maxValue,minValue,range,tan,[0.0,0.0],0.0,0.0)
        end
        function Triangle(name,a,c,intersectionPoint,innerArea,innerCenter,height=1.0)
            maxValue = max(a,c)
            minValue = min(a,c)
            range = maxValue - minValue
            tan = range / (2*height)
            return new(name,minValue,maxValue,((a+c)/2),height,maxValue,minValue,range,tan,intersectionPoint,innerArea,innerCenter)
        end
    end


    type DoesNotExistTerm <: Term
    end

    type DoesNotMatterTerm <: Term
    end

    isdefined(:membership) || include("membership.jl")
    isdefined(:Accumulated) || include("Accumulated.jl")
end
