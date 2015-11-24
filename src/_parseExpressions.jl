function _parseExpressions(engine::EngineSkeleton, propositions::Vector{String}, T::Type)
    index = 1
    hasOR = false
    hasAND = false
    lengthProp = length(propositions)
    finalLength = 0;

    if lengthProp >= 3

        currentExpr::Expression = _parseProposition(engine,propositions, T,index)

        finalLength = finalLength + 1

        while (index+4) <= lengthProp

            hasOR = uppercase(propositions[index+3]) == "OR"? true: !(hasAND = uppercase(propositions[index+3]) == "AND")

            if(hasOR || hasAND)

                index += 4

                operator::LogicalOperator = hasOR?Or():And()
                hasOR = false
                hasAND = false

                prop::Proposition = _parseProposition(engine,propositions, T,index)
                finalLength = finalLength + 1

                currentExpr = Operator(prop,operator,currentExpr)
            else
                throw(ParseError("AND or OR keyword not found"))
            end
        end

        return (currentExpr,finalLength)
    end
end

function _parseExpressions(engine::EngineSkeleton, propositions::Vector{SubString{ASCIIString}}, T::Type)
    index = 1
    hasOR = false
    hasAND = false
    lengthProp = length(propositions)
    finalLength = 0;

    if lengthProp >= 3

        currentExpr::Expression = _parseProposition(engine,propositions, T,index)

        finalLength = finalLength + 1

        while (index+4) <= lengthProp

            hasOR = uppercase(propositions[index+3]) == "OR"? true: !(hasAND = uppercase(propositions[index+3]) == "AND")

            if(hasOR || hasAND)

                index += 4

                operator::LogicalOperator = hasOR?Or():And()
                hasOR = false
                hasAND = false

                prop::Proposition = _parseProposition(engine,propositions, T,index)
                finalLength = finalLength + 1

                currentExpr = Operator(prop,operator,currentExpr)
            else
                throw(ParseError("AND or OR keyword not found"))
            end
        end

        return (currentExpr,finalLength)
    end
end

