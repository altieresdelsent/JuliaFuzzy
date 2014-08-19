function _updateRulesBlocks!{T <: Variable}(variablesSkeleton::Array{T,1}, ruleBlocks::Array{RuleBlock,1},variables,verbose = false)
    (verbose) && print("starting _updateRulesBlocks")
    (verbose) && print("\n")
    for variableSkeleton in variablesSkeleton
        variable = getVariable(variables,variableSkeleton.name)
        (verbose) && print("updating rules with variable")
        (verbose) && print(variableSkeleton.name)
        (verbose) && print("\n")
        for ruleBlock in ruleBlocks
            for rule in ruleBlock.rules
                if rule.antecedent.head.variable == variableSkeleton
                    rule.antecedent.head.variable = variable
                end
                if rule.consequent.head.variable == variableSkeleton
                    rule.consequent.head.variable = variable
                end
                for operator::Operator in rule.antecedent.tail
                    if operator.left.variable == variableSkeleton
                        operator.left.variable = variable
                    end
                end
                for operator::Operator in rule.consequent.tail
                    if operator.left.variable == variableSkeleton
                        operator.left.variable = variable
                    end
                end
            end
        end
    end
    (verbose) && print("ending _updateRulesBlocks")
    (verbose) && print("\n")
end
