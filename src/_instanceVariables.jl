function _instanceVariables(variablesSkeleton,variablesType,loadType, verbose = false)
    (verbose) && print("starting _instanceVariables")
    (verbose) && print("\n")
    functionParenthesis = Array(Any,1+ length(variablesSkeleton))
    counter = 0
    #first parameters has to be the tipe
    counter = counter + 1
    functionParenthesis[counter] = variablesType
    for variableSkeleton in variablesSkeleton
        counter = counter + 1
        newVariable = _instanceVariable(variableSkeleton,variableSkeleton.typeFinal,loadType,verbose)
        functionParenthesis[counter] = newVariable
    end

    #call a function ( first parameter, with parameters ( the otheres index in the functionParenthesis vector
    callFunc = Expr(:call,functionParenthesis...)
    inner = Expr(:(=),:y,callFunc)
    b = Expr(:block,inner)
    (verbose) && print("ending _instanceVariables")
    (verbose) && print("\n")
    newInstanceVariables = eval(b)
    (verbose) && print("printing result _instanceVariables")
    (verbose) && print("\n")
    (verbose) && print(newInstanceVariables)
    (verbose) && print("\n")
    return newInstanceVariables
end
