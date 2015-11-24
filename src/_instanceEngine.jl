function _instanceEngine(engineSkeleton,engineType,verbose = false)
    (verbose) && print("starting instance engine")
    (verbose) && print("\n")
    functionParenthesis = Array(Any,0)
    counter = 0
    #first parameters has to be the tipe
    push!(functionParenthesis,engineType)

    inputVariables::baseInputVariables = _instanceVariables(engineSkeleton.inputVariables,engineSkeleton.inputsType,InputVariable,verbose)
    outputVariables::baseOutputVariables  = _instanceVariables(engineSkeleton.outputVariables,engineSkeleton.outputsType,OutputVariable,verbose)

    push!(functionParenthesis,inputVariables)
    push!(functionParenthesis,outputVariables)

    _updateRulesBlocks!(engineSkeleton.inputVariables,engineSkeleton.ruleBlocks,inputVariables,verbose)
    _updateRulesBlocks!(engineSkeleton.outputVariables,engineSkeleton.ruleBlocks,outputVariables,verbose)

    push!(functionParenthesis,engineSkeleton.ruleBlocks)

    push!(functionParenthesis,engineSkeleton.conjunction)
    push!(functionParenthesis,engineSkeleton.disjunction)
    push!(functionParenthesis,engineSkeleton.activation)
    push!(functionParenthesis,engineSkeleton.accumulation)
    push!(functionParenthesis,engineSkeleton.defuzzifier)

    counter = 1
    #print(engineType.types)
    #print("\n")
    #for item in functionParenthesis
    #        print(typeof(item))
    #        print(",")
    #end
    #print("\n")
    callFunc = Expr(:call,functionParenthesis...)
    inner = Expr(:(=),:y,callFunc)
    b = Expr(:block,inner)
    (verbose) && print("ending instance engine..")
    (verbose) && print("\n")
    newInstance = eval(b)
    (verbose) && print("printing result _instanceEngine")
    (verbose) && print("\n")
    (verbose) && print(newInstance)
    (verbose) && print("\n")
    return newInstance

end
