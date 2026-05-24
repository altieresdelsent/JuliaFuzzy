using ..Terms: DoesNotExistTerm
using ..Variables: DoesNotExistVariable
function getTerm(variable::DoesNotExistVariable, name::Symbol)
    return DoesNotExistTerm()
end
function getTerm(variable::T, name::Symbol) where T <: Variable
    for term in variable.terms
        if term.name == name
            return term
        end
    end
    return DoesNotExistTerm()
end
