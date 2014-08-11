function configure(engine::EngineSkeleton)
    for ruleBlock::RuleBlock in engine.ruleBlocks
        ruleBlock.conjunction = engine.conjunction
        ruleBlock.disjunction = engine.disjunction
        ruleBlock.activation = engine.activation
    end

    for variable::OutputVariable in engine.outputVariables
        variable.defuzzifier = engine.defuzzifier
        variable.fuzzyOutput.accumulation = engine.accumulation
    end
end
