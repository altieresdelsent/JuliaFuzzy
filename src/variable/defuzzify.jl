using ..Defuzzifiers

#using Debug
 function defuzzify(output::baseOutputVariable)
    # cache return this is the most expensive part.
    output.lastValidOutput = Defuzzifiers.defuzzify(output.defuzzifier, output)
    return output.lastValidOutput
end
