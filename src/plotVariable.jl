using .Terms
using .Terms.membership
using Gadfly
function plotVariable(variable)
    terms = Array(Function,0)
    finalMax = realmin(0.0)
    finalMin = realmax(0.0)
    for term in variable.terms
        b = (x) -> membership(term,x)
        push!(terms,b)
        finalMax = max(finalMax,term.maxValue)
        finalMin = min(finalMin,term.minValue)
    end
    Gadfly.plot(terms,finalMin, finalMax)
end
