module Terms
    #using Debug

    using ..Norms: SNorm
    using ..Norms: TNorm
    abstract type Term end

    mutable struct Activated{T <: AbstractFloat, B <: Term} <: Term
        term::B
        degree::T
        activation::TNorm
    end

    mutable struct Accumulated{T <: AbstractFloat} <: Term
        terms::Array{Activated,1}
        minimum::T
        maximum::T
        accumulation::SNorm
        function Accumulated{T}() where T <: AbstractFloat
            acc = new{T}()
            acc.terms = Activated[]
            acc.minimum = prevfloat(typemax(T))
            acc.maximum = prevfloat(typemin(T))
            return acc
        end
    end


    mutable struct Bell{T <: AbstractFloat, B <: Term} <: Term
        terms::Array{B,1}
        center::T
        width::T
        slope::T
        acumulation::SNorm
    end

    mutable struct Constant{T <: AbstractFloat} <: Term
        value::T
    end

    mutable struct Discrete{T <: AbstractFloat} <: Term
        x::Array{T,1}
        y::Array{T,1}
    end

    mutable struct functionTerm <: Term
    end
    const GaussianType_Left = -1
    const GaussianType_Normal = 0
    const GaussianType_Right = 1

    struct Gaussian{T <: AbstractFloat} <: Term
        name::Symbol
        mean::T
        standardDeviation::T
        height::T
        maxValue::T
        minValue::T
        gaussType::Int64
        function Gaussian{T}(name,mean,standardDeviation,typeG=GaussianType_Normal,height=1.0) where T <: AbstractFloat
            minValue = mean-(5*standardDeviation)
            maxValue = mean+(5*standardDeviation)
            return new{T}(name,mean,standardDeviation,height,maxValue,minValue,typeG)
        end
    end
    struct Sigmoid{T <: AbstractFloat} <: Term
        name::Symbol
        slope::T
        inflection::T
        height::T
        maxValue::T
        minValue::T
        function Sigmoid{T}(name,slope,inflection,height=1.0) where T <: AbstractFloat
            minValue = inflection-(6*slope)
            maxValue = inflection+(6*slope)
            return new{T}(name,slope,inflection,height,maxValue,minValue)
        end
    end

    struct GaussianProduct{T <: AbstractFloat} <: Term
        meanA
        standardDeviationA
        meanB
        standardDeviationB
    end
    struct Trapezoid{T <: AbstractFloat} <: Term
        name::Symbol
        vertexA::T
        vertexB::T
        vertexC::T
        vertexD::T
        height::T
        maxValue::T
        minValue::T
        function Trapezoid{T}(name,a,b,c,d,height=1.0) where T <: AbstractFloat
            new{T}(name,a,b,c,d,height,a,d)
        end
    end
    struct Triangle{T <: AbstractFloat} <: Term
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
        function Triangle{T}(name,a,c,height=1.0) where T <: AbstractFloat
            maxValue = max(a,c)
            minValue = min(a,c)
            range = maxValue - minValue
            tan = range / (2*height)
            return new{T}(name,minValue,maxValue,((a+c)/2),height,maxValue,minValue,range,tan,[0.0,0.0],0.0,0.0)
        end
        function Triangle{T}(name,a,c,intersectionPoint,innerArea,innerCenter,height=1.0) where T <: AbstractFloat
            maxValue = max(a,c)
            minValue = min(a,c)
            range = maxValue - minValue
            tan = range / (2*height)
            return new{T}(name,minValue,maxValue,((a+c)/2),height,maxValue,minValue,range,tan,intersectionPoint,innerArea,innerCenter)
        end
    end


    mutable struct DoesNotExistTerm <: Term
    end

    mutable struct DoesNotMatterTerm <: Term
    end

    isdefined(@__MODULE__, :membership) || include("membership.jl")
    isdefined(@__MODULE__, :Accumulated) || include("Accumulated.jl")
end
