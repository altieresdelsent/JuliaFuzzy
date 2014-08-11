function _parseProposition(engine::EngineSkeleton,propositions::Array{String,1}, T::Type,index::Int)

    variable = getVariable(engine,symbol(propositions[index+2]),T)
    hasVariable = (variable != DoesNotExistVariable()) ? true: throw(ParseError(" Variable $inputs[index+3]  not found"))

    hasIS = (uppercase(propositions[index+1]) == "IS")?true: throw(ParseError(" IS keyword not found"))

    term = getTerm(variable,symbol(propositions[index]))
    hasTerm = (term != DoesNotExistTerm()) ? true: throw(ParseError(" Term $inputs[index]  not found"))
    return Proposition(variable,term)
end
