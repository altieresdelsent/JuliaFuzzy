#using Debug
using .LinearAlgebra.LinearFunc
using .LinearAlgebra.solveFast
using .Terms.Triangle
 function configure(engine::EngineSkeleton)
    
    for ruleBlock::RuleBlock in engine.ruleBlocks
        ruleBlock.conjunction = engine.conjunction
        ruleBlock.disjunction = engine.disjunction
        ruleBlock.activation = engine.activation
    end
    

    for variable::OutputVariable in engine.outputVariables
        variable.defuzzifier = engine.defuzzifier
        variable.fuzzyOutput.accumulation = engine.accumulation
        accumulator = variable.fuzzyOutput
        index = 0

        for ruleBlock::RuleBlock in engine.ruleBlocks
        	for rule::Rule in ruleBlock.rules
	        	proposition = rule.consequent.head
	        	added = false
	        	if proposition.variable == variable
	        		push!(accumulator.terms, Activated{typeof(0.0),typeof(proposition.term)}(proposition.term,0.0,engine.activation))
	        		added = true
	        	else 
				    for operator::Operator in rule.consequent.tail
				    	proposition = operator.left
				    	if proposition.variable == variable
					    	push!(accumulator.terms, Activated{typeof(0.0),typeof(proposition.term)}(proposition.term,0.0,engine.activation))
					    	added = true
					    	break
					    end
				    end
				end

				if !added
					push!(accumulator.terms, Activated{typeof(0.0),DoesNotMatterTerm}(DoesNotMatterTerm(),0.0,engine.activation))
				end
			end
		end
		
		#@bp
    end
end
