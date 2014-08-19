module Variables

using ..Terms.Term
using ..Terms.Accumulated
using ..Terms.DoesNotExistTerm
using ..Terms.Term

using ..Defuzzifiers.Defuzzifier
using ..Defuzzifiers.Centroid
abstract Variable

abstract baseInputVariable <: Variable
abstract baseOutputVariable <: Variable

abstract baseVariables
abstract baseInputVariables <: baseVariables
abstract baseOutputVariables <: baseVariables

type InputVariable{T <: FloatingPoint} <: baseInputVariable
    value::T
    name::Symbol
    maxValue::T
    minValue::T
    terms::Array{Term,1}
    typeFinal::DataType
    function InputVariable{T <: FloatingPoint}(value::T = 0.0,
            name = :nothing,
            maxValue::T = 0.0,
            minValue::T = 0.0,
            terms = Array(Term,0))
        this = new()
        this.value = value
        this.name = name
        this.maxValue = maxValue
        this.minValue = minValue
        this.terms = terms
        this.typeFinal = InputVariable
        return this
    end
end


type OutputVariable{T <: FloatingPoint} <: baseOutputVariable
    name::Symbol

    defuzzifier::Defuzzifier;
    maxValue::T
    minValue::T
    terms::Array{Term,1}

    fuzzyOutput::Accumulated{T}
    lastValidOutput::T
    _lockOutputRange::Bool
    _lockValidOutput::Bool
    _defaultValue::T
    typeFinal::DataType

    function OutputVariable()
        newOutput = new()
        newOutput.name = :nothing
        newOutput.defuzzifier = Centroid{T}(200.0)
        newOutput.maxValue = 0.0
        newOutput.minValue = 0.0
        newOutput.terms = Array(Term,0)
        newOutput.fuzzyOutput = Accumulated{T}()
        newOutput.lastValidOutput = 0.0
        newOutput._lockOutputRange = false
        newOutput._lockValidOutput = false
        newOutput._defaultValue = 0.0
        newOutput.typeFinal = OutputVariable
        return newOutput
    end
end

type DoesNotExistVariable <: Variable
end

include("defuzzify.jl")
include("getTerm.jl")

macro createTest(Name)
x = quote
    type $(Name)
    end
end
return eval(x)
end



end
