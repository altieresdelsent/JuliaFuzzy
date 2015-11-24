using ..Terms.Activated
#using Debug 
 function cleanFuzzyOutput(conclusion::Consequent)
    cleanFuzzyOutput(conclusion.head)
    for operator::Operator in conclusion.tail
        cleanFuzzyOutput(operator.left)
    end
end
function cleanFuzzyOutput(proposition::Proposition)
	for term in proposition.variable.fuzzyOutput.terms
		term.degree = 0.0
	end    
end
