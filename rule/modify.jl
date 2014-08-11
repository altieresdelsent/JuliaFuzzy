using ..Terms.Activated

function modify(conclusion::Consequent,degree, activation::TNorm)
    modify(conclusion.head,degree,activation)
    for operator::Operator in conclusion.tail
        modify(operator.left,degree,activation)
    end
end
function modify(proposition::Proposition,degree,activation::TNorm)
    activated = Activated{typeof(degree),typeof(proposition.term)}(proposition.term,degree,activation)
    push!(proposition.variable.fuzzyOutput.terms,activated)
end

