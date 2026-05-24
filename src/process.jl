#print(current_module())
#using Debug
using .Rules: activate
using .Variables: defuzzify
 function process(engine)
	counter = 0
    for ruleBlock in engine.ruleBlocks        
        counter = counter + activate(ruleBlock,counter)
    end
    for ov in engine.outputVariables
        defuzzify(ov)
    end
end
