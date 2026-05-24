module Variables
#using Debug

using ..Terms: Term
using ..Terms: Accumulated
using ..Terms: DoesNotExistTerm

using ..Defuzzifiers: Defuzzifier
using ..Defuzzifiers: Centroid
abstract type Variable end

abstract type baseInputVariable <: Variable end
abstract type baseOutputVariable <: Variable end

abstract type baseVariables end
abstract type baseInputVariables <: baseVariables end
abstract type baseOutputVariables <: baseVariables end

mutable struct InputVariable{T <: AbstractFloat} <: baseInputVariable
    value::T
    name::Symbol
    maxValue::T
    minValue::T
    terms::Array{Term,1}
    typeFinal::DataType
    function InputVariable{T}(value::T = 0.0,
            name = :nothing,
            maxValue::T = 0.0,
            minValue::T = 0.0,
            terms = Term[]) where T <: AbstractFloat
        this = new{T}()
        this.value = value
        this.name = name
        this.maxValue = maxValue
        this.minValue = minValue
        this.terms = terms
        this.typeFinal = InputVariable
        return this
    end
end


mutable struct OutputVariable{T <: AbstractFloat} <: baseOutputVariable
    name::Symbol

    defuzzifier::Defuzzifier;
    maxValue::T
    minValue::T
    terms::Array{Term,1}
    termsActivation::Dict{Symbol,T}


    fuzzyOutput::Accumulated{T}
    lastValidOutput::T
    _lockOutputRange::Bool
    _lockValidOutput::Bool
    _defaultValue::T
    typeFinal::DataType

    function OutputVariable{T}() where T <: AbstractFloat
        newOutput = new{T}()
        newOutput.name = :nothing
        newOutput.defuzzifier = Centroid{T}(200.0)
        newOutput.maxValue = 0.0
        newOutput.minValue = 0.0
        newOutput.terms = Term[]
        newOutput.termsActivation = Dict{Symbol,T}()
        newOutput.fuzzyOutput = Accumulated{T}()
        newOutput.lastValidOutput = 0.0
        newOutput._lockOutputRange = false
        newOutput._lockValidOutput = false
        newOutput._defaultValue = 0.0
        newOutput.typeFinal = OutputVariable
        return newOutput
    end
end

mutable struct DoesNotExistVariable <: Variable
end

isdefined(@__MODULE__, :defuzzify) || include("defuzzify.jl")
isdefined(@__MODULE__, :getTerm) || include("getTerm.jl")

macro createTest(Name)
x = quote
    mutable struct $(Name)
    end
end
return eval(x)
end



end
