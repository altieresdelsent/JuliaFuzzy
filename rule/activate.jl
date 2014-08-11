function activate(ruleBlock::RuleBlock)
    for rule in ruleBlock.rules
        cleanFuzzyOutput(rule.consequent)
    end
    for rule in ruleBlock.rules
        degree = activationDegree(rule,ruleBlock.conjunction,ruleBlock.disjunction)
        #print("\tdegree:")
        #print("$degree")
        #print("\n")
        if(degree > 0)
            #print(rule.consequent)
            #print("\n")
            modify(rule.consequent, degree,ruleBlock.activation)
        end
    end
end



