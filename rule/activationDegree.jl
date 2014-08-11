using ..Terms.membership
using ..Norms.compute

function activationDegree(rule::Rule, conjuction::TNorm, disjunction::SNorm)
    proposition::Proposition = rule.antecedent.head;
    value = membership(proposition.term,proposition.variable.value)
    #print("\tstarting log activationDegree")
    #print("\n")
    #print("\t\tterm:")
    #print("$(proposition.term.name)")
    #print("\n")
    #print("\t\tvariable:")
    #print("$(proposition.variable.name)")
    #print("\n")
    #print("\t\tvalue Membership:")
    #print("$value")
    #print("\n")
    #print("\tending log activationDegree")
    #print("\n")
    for operator::Operator in rule.antecedent.tail
        proposition = operator.left
        value2 = membership(proposition.term,proposition.variable.value)
        if(operator.operator == Or())
            value = compute(conjuction,value,value2)
        elseif(operator.operator == And())
            value = compute(disjunction,value,value2)
        end
        #print("\tnext log activationDegree")
        #print("\n")
        #print("\t\tterm:")
        #print("$(proposition.term.name)")
        #print("\n")
        #print("\t\tvariable:")
        #print("$(proposition.variable.name)")
        #print("\n")
        #print("\t\tvalue Membership:")
        #print("$value")
        #print("\n")
        #print("\t\tvalue2 Membership:")
        #print("$value2")
        #print("\n")
        #print("\tending log activationDegree")
        #print("\n")
    end

    return value
end
