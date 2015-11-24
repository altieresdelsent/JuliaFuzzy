#using Debug
function activate(ruleBlock, startIndex)
    #for rule in ruleBlock.rules
    #    cleanFuzzyOutput(rule.consequent)
    #    break
    #end

    index = startIndex
    for rule in ruleBlock.rules
        index = index + 1
        degree = activationDegree(rule,ruleBlock.conjunction,ruleBlock.disjunction)
        if degree > 1e-5
            modifyConsequent(rule.consequent, degree, index)
        else
            modifyConsequent(rule.consequent, 0.0, index) 
        end
    end
    return index
end



