function getVariable(engine::EngineSkeleton,name::Symbol,T)
    variables = (T == InputVariable)? engine.inputVariables :
                (T == OutputVariable)? engine.outputVariables :
                DoesNotExistVariable();
    for variable::T in variables
        if variable.name == name
            return variable
        end
    end
    return DoesNotExistVariable()
end
