#print(current_module())
using .Rules.activate
function process(engine::Engine)
    for ruleBlock in engine.ruleBlocks
        activate(ruleBlock)
    end
end
