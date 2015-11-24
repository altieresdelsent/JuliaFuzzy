function _generateVariables(variablesSkeleton,loadType,verbose::Bool = false)
    nameType::Symbol = :nothing
    while true
        newName = randstring(10)
        nameType = symbol("_$newName")
        if !isdefined(nameType)
            break;
        end
    end
    
    lengthVariablesSkeleton = length(variablesSkeleton)
    variables = Array(Expr,lengthVariablesSkeleton)
    counter = 0
    for variableSkeleton in variablesSkeleton
        counter = counter + 1
        (verbose) && print("\tstarting generating variable")
        (verbose) && print(variableSkeleton.name)
        (verbose) && print("\n")
        typeVariableSkeleton = _generateVariable(variableSkeleton,loadType,verbose)
        (verbose) && print("\tending generating variable")
        (verbose) && print(variableSkeleton.name)
        (verbose) && print("\n")
        variables[counter] = Expr(:(::),variableSkeleton.name,typeVariableSkeleton)
    end

    if(loadType == InputVariable)
        base = baseInputVariables
    elseif (loadType == OutputVariable)
        base = baseOutputVariables
    end

    fieldsExpr = Expr(:block,variables...)
    typeExpr = Expr(:<:,[nameType,base]...)
    newTypeVariablesExpr = Expr(:type,[true,typeExpr,fieldsExpr]...)

    verbose && print(newTypeVariablesExpr)
    verbose && print("\n")

    eval(newTypeVariablesExpr)

    verbose && print("New container variable generated:")
    newContainerVariables::DataType = eval(nameType)
    verbose && print(newContainerVariables)
    verbose && print("\n")
    return newContainerVariables
end
