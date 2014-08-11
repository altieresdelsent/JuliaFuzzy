module Variables

using ..Terms.Term
using ..Terms.Accumulated
using ..Terms.DoesNotExistTerm

using ..Defuzzifiers.Defuzzifier
using ..Defuzzifiers.Centroid
abstract Variable
abstract baseInputVariable <: Variable
abstract baseOutputVariable <: Variable

type InputVariable{T <: FloatingPoint} <: baseInputVariable
    value::T
    name::Symbol
    maxValue::T
    minValue::T
    terms::Array{Term,1}
    InputVariable() = new()
end


type OutputVariable{T <: FloatingPoint} <: baseOutputVariable
    name::Symbol

    defuzzifier::Defuzzifier;
    maxValue::T
    minValue::T
    terms::Array{Term,1}

    fuzzyOutput::Accumulated{T};
    lastValidOutput::T;
    _lockOutputRange::Bool;
    _lockValidOutput::Bool;
    _defaultValue::T;




    function OutputVariable()
        newOutput = new()
        newOutput.fuzzyOutput = Accumulated{T}()
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
