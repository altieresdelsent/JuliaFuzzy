using ..Terms.Activated

function cleanFuzzyOutput(conclusion::Consequent)
    cleanFuzzyOutput(conclusion.head)
    for operator::Operator in conclusion.tail
        cleanFuzzyOutput(operator.left)
    end
end
function cleanFuzzyOutput(proposition::Proposition)
    proposition.variable.fuzzyOutput.terms = Array(Activated,0)
end
