#print(current_module())
#using Debug
using .Rules.activate
 function process(engine)
	counter = 0
    for ruleBlock in engine.ruleBlocks        
        counter = counter + activate(ruleBlock,counter)
    end
end
