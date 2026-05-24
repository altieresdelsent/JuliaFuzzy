function parseRule(engine::EngineSkeleton,rule::AbstractString)
    if occursin(r"\sthen\s"i, rule)
        parts = split(rule, r"\sthen\s"i; keepempty=false)

        input = convert(AbstractString,parts[1])
        output = convert(AbstractString,parts[2])
        inputs = split(input, " "; keepempty=false)

        if uppercase(inputs[1]) == "IF"
            (firstExpr,finaLength) = _parseExpressions(engine,reverse!(inputs),InputVariable)
            (headInput, tailInput) = Rules.toArrayExpression(firstExpr,finaLength)

            outputs = split(output, " "; keepempty=false)
            (firstExpr,finaLength) = _parseExpressions(engine,reverse!(outputs),OutputVariable)
            (headOutput, tailOutput) = Rules.toArrayExpression(firstExpr,finaLength)

            ruleParsed = Rule(Antecedent(headInput, tailInput),Consequent(headOutput, tailOutput))
            #return ruleParsed
        else
            throw(ParseError("IF keyword not found"))
        end
    else
        throw(ParseError("THEN keyword not found"))
    end

end
