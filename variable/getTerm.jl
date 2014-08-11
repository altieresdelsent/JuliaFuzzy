function getTerm{T <: Variable}(variable::T, name::Symbol)
    for term in variable.terms
        if term.name == name
            return term
        end
    end
    return DoesNotExistTerm()
end
