using ..Defuzzifiers
function defuzzify(output::baseOutputVariable)
    # cache return this is the most expensive part.
    output.lastValidOutput = Defuzzifiers.defuzzify(output.defuzzifier, output.fuzzyOutput, output.minValue, output.maxValue)
    return output.lastValidOutput
end
