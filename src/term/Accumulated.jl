using ..Norms.DoesNotExistNorm
using ..Norms.compute


function activationDegree(tMember::Accumulated,forTerm::Term)
    result = 0.0;
    for term::Activated in tMember.terms
        activatedTerm::Activated = term;
        if activatedTerm.term == forTerm
            if tMember.accumulation != DoesNotExistNorm()
                #print("hadukiiii")
                result = compute(tMember.accumulation, result, activatedTerm.degree);
            else
                result = result + activatedTerm.degree;#Default for WeightDefuzzifier
            end
        end
    end
    return result;
end
