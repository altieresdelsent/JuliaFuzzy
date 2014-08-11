module Terms
    using ..Norms.SNorm
    using ..Norms.TNorm
    abstract Term

    type Activated{T <: FloatingPoint, B <: Term} <: Term
        term::B
        degree::T
        activation::TNorm
    end

    type Accumulated {T <: FloatingPoint} <: Term
        terms::Array{Activated,1}
        minimum::T
        maximum::T
        accumulation::SNorm
        function Accumulated()
            acc = new()
            acc.terms = Array(Activated,0)
            acc.minimum = 0.0
            acc.maximum = 0.0
            return acc
        end
    end


    type Bell {T <: FloatingPoint, B <: Term} <: Term
        terms::Array{B,1}
        center::T;
        width::T;
        slope::T;
        acumulation::SNorm
    end

    type Constant {T <: FloatingPoint} <: Term
        value::T;
    end

    type Discrete {T <: FloatingPoint} <: Term
        x::Array{T,1};
        y::Array{T,1};
    end

    type FunctionTerm <: Term
    end

    type Gaussian{T <: FloatingPoint} <: Term
        name::Symbol
        mean::T;
        standardDeviation::T;
        height::T;
        function Gaussian(name,mean,standardDeviation,height=1.0)
            return new(name,mean,standardDeviation,height)
        end
    end

    type GaussianProduct{T <: FloatingPoint} <: Term
        meanA;
        standardDeviationA;
        meanB;
        standardDeviationB;
    end
    type Trapezoid{T <: FloatingPoint} <: Term
        name::Symbol
        vertexA::T
        vertexB::T
        vertexC::T
        vertexD::T
        height::T
    end
    type Triangle{T <: FloatingPoint} <: Term
        name::Symbol
        vertexA::T;
        vertexC::T;
        vertexB::T;
        height::T;
        function Triangle(name,a,c,height=1.0)
            new(name,a,c,((a+c)/2),height)
        end
    end


    type DoesNotExistTerm <: Term
    end

    include("membership.jl")
    include("Accumulated.jl")
end
