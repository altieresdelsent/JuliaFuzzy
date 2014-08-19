using .Variables.baseVariables
function getVariable(engine::EngineSkeleton,name::Symbol,T)
    if(T <: Variable)
        variables = (T <: InputVariable)? engine.inputVariables :
                    engine.outputVariables;
        return getVariable(variables,name)
    else
        throw( ParseError("Typed passed is not variable"))
    end
end
function getVariable{T <: Variable}(variables::Array{T,1},name::Symbol)
    for variable in variables
        if variable.name == name
            return variable
        end
    end
    return DoesNotExistVariable()
end
function getVariable(variables::baseVariables, name::Symbol)
    symbolName = Expr(:quote,name)
    return eval(Expr(:.,variables,symbolName))
end
