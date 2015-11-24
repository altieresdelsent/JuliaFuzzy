function _instanceVariable(variableSkeleton,variableType,loadType, verbose = false)
    (verbose) && print("starting _instanceVariable")
    (verbose) && print("\n")
    functionParenthesis = Array(Any,1+ length(variableSkeleton.terms))
    counter = 0
    counter = counter + 1
    #first parameters has to be the type
    functionParenthesis[counter] = variableType
    for term in variableSkeleton.terms
        counter = counter + 1
        functionParenthesis[counter] = term
    end
    if(loadType == InputVariable)
        _loadExtraFieldsInput!(functionParenthesis,variableSkeleton)
    elseif (loadType == OutputVariable)
        _loadExtraFieldsOutput!(functionParenthesis,variableSkeleton)
    end

    #call a function ( first parameter, with parameters ( the otheres index in the functionParenthesis vector
    callFunc = Expr(:call,functionParenthesis...)
    inner = Expr(:(=),:y,callFunc)
    b = Expr(:block,inner)
    (verbose) && print("ending _instanceVariable")
    (verbose) && print("\n")
    newInstanceVariable = eval(b)
    (verbose) && print("printing result _instanceVariable")
    (verbose) && print("\n")
    (verbose) && print(newInstanceVariable)
    (verbose) && print("\n")
    return newInstanceVariable
end
