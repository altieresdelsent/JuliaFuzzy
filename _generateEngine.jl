function _generateEngine(engineSkeleton::EngineSkeleton, verbose = false)
    nameType::Symbol = :nothing
    while true
        newName = randstring(10)
        nameType = symbol("_$newName")
        if !isdefined(nameType)
            break;
        end
    end
    fields = Array(Expr,0)
    (verbose) && print("starting generating input variables")
    (verbose) && print("\n")
    newTypeInputs = _generateVariables(engineSkeleton.inputVariables,InputVariable,verbose)
    engineSkeleton.inputsType = newTypeInputs
    (verbose) && print("ending generating input variables")
    (verbose) && print("\n")

    (verbose) && print("starting generating output variables")
    (verbose) && print("\n")
    newTypeOutputs = _generateVariables(engineSkeleton.outputVariables,OutputVariable,verbose)
    engineSkeleton.outputsType = newTypeOutputs
    (verbose) && print("ending generating output variables")
    (verbose) && print("\n")

    push!(fields,Expr(:(::),:inputVariables,newTypeInputs))
    push!(fields,Expr(:(::),:outputVariables,newTypeOutputs))
    push!(fields,Expr(:(::),:ruleBlocks,Array{RuleBlock,1}))


    push!(fields,Expr(:(::),:conjunction,TNorm))
    push!(fields,Expr(:(::),:disjunction,SNorm))
    push!(fields,Expr(:(::),:activation,TNorm))
    push!(fields,Expr(:(::),:accumulation,SNorm))
    push!(fields,Expr(:(::),:defuzzifier,Defuzzifier))

    inner = Expr(:block,fields...)
    typeExpr = Expr(:<:,[nameType,Engine]...)
    newTypeEngineExpr = Expr(:type,[true,typeExpr,inner]...)
    (verbose) && print("starting generating engine type")
    (verbose) && print("\n")
    (verbose) && print(newTypeEngineExpr)
    (verbose) && print("\n")
    eval(newTypeEngineExpr)
    (verbose) && print("ending generating engine type")
    newTypeEngine::DataType = eval(nameType)
    (verbose) && print(newTypeEngine)
    (verbose) && print("\n")


    return newTypeEngine
end
