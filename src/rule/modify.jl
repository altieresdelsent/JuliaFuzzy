using ..Terms.Activated
using ..Terms.DoesNotMatterTerm
#using Debug 
const eliminateTerm = DoesNotMatterTerm()
function modifyConsequent(conclusion,degree, index)
    modify(conclusion.head,degree, index)
    for operator in conclusion.tail
        modify(operator.left,degree, index)
    end
end
 function modify(proposition,degree, index)
    accumulator = proposition.variable.fuzzyOutput
    
    if accumulator.terms[index].term != eliminateTerm

        #accumulator.minimum = min(proposition.variable.minValue,accumulator.minimum)
        #accumulator.maximum = max(proposition.variable.maxValue,accumulator.maximum)

        accumulator.terms[index].degree = degree
    end
    # = Activated{typeof(degree),typeof(proposition.term)}(proposition.term,degree,activation)
    #push!(,activated)
end

