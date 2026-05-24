function _parseProposition(engine::EngineSkeleton,propositions::Vector{AbstractString}, T::Type,index::Int)

    variable = getVariable(engine,Symbol(propositions[index+2]),T)
    hasVariable = (variable != DoesNotExistVariable()) ? true : throw(ParseError(" Variable $(propositions[index+2])  not found"))

    hasIS = (uppercase(propositions[index+1]) == "IS") ? true : throw(ParseError(" IS keyword not found"))

    term = getTerm(variable,Symbol(propositions[index]))
    hasTerm = (term != DoesNotExistTerm()) ? true : throw(ParseError(" Term $(propositions[index])  not found"))
    return Proposition(variable,term)
end

function _parseProposition(engine::EngineSkeleton,propositions::Vector{SubString{String}}, T::Type,index::Int)

    variable = getVariable(engine,Symbol(propositions[index+2]),T)
    hasVariable = (variable != DoesNotExistVariable()) ? true : throw(ParseError(" Variable $(propositions[index+2])  not found"))

    hasIS = (uppercase(propositions[index+1]) == "IS") ? true : throw(ParseError(" IS keyword not found"))

    term = getTerm(variable,Symbol(propositions[index]))
    hasTerm = (term != DoesNotExistTerm()) ? true : throw(ParseError(" Term $(propositions[index])  not found"))
    return Proposition(variable,term)
end
