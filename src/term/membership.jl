using ..Norms.compute
#using Debug
function membership(tMember::Accumulated, crispValue)
    mu = 0.0;
    for term::Activated in tMember.terms
        #print("mu:$mu")
        mu = compute(tMember.accumulation, mu, membership(term,crispValue))
    end
    return mu
end

function membership(tMember::Activated,crispValue)
    return compute(tMember.activation,membership(tMember.term,crispValue), tMember.degree);
end

 function membership(tMember::Gaussian, crispValue)
    return tMember.height * exp((-(crispValue - tMember.mean) * (crispValue - tMember.mean)) / (2 * tMember.standardDeviation * tMember.standardDeviation));
end

 function membership(tMember::Sigmoid, crispValue)
    #@bp
    return tMember.height * 1.0 / (1.0 + exp(-tMember.slope * (crispValue - tMember.inflection)))
end

function membership(tMember::Trapezoid, crispValue )

    if crispValue < tMember.vertexA || crispValue > tMember.vertexD
        return tMember.height * 0.0;
    end
    if crispValue < tMember.vertexB
        return tMember.height * minimum(scalar(1.0), (crispValue - tMember.vertexA) / (tMember.vertexB - tMember.vertexA));
    end
    if crispValue <= tMember.vertexC
        return tMember.height * 1.0;
    end
    if crispValue < tMember.vertexD
        return tMember.height * (tMember.vertexD - crispValue) / (tMember.vertexD - tMember.vertexC);
    end
    return tMember.height * 0.0;
end

function membership(tMember::Triangle, crispValue )
#print("{$(tMember.name)")
#print(",$(tMember.vertexA)")
#print(",$(tMember.vertexB)")
#print(",$(tMember.vertexC)")
#print(",$(crispValue)}")
    if (crispValue < tMember.vertexA) || (crispValue > tMember.vertexC)
        return tMember.height * 0.0;
    elseif crispValue == tMember.vertexB
        return tMember.height * 1.0;
    elseif crispValue < tMember.vertexB
        return tMember.height * (crispValue - tMember.vertexA) / (tMember.vertexB - tMember.vertexA);
    else
        return tMember.height * (tMember.vertexC - crispValue) / (tMember.vertexC - tMember.vertexB);
    end
end
