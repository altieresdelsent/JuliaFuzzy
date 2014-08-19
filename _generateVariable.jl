    #this method is closed related with _instanceVariable, if you alter one
    # you HAVE to alter the other, this method creates the structure and the _instanceVariable load
    # the same structure in memory
    function _generateVariable(variableSkeleton,loadType,verbose = false)
        nameType::Symbol = :nothing
        base = Int64
        while true
            newName = randstring(10)
            nameType = symbol("_$newName")
            if !isdefined(nameType)
                break;
            end
        end
        terms = _generateTerms(variableSkeleton.terms)

        if(loadType == InputVariable)
            _addExtraFieldsInput!(terms)
            base = baseInputVariable
        elseif (loadType == OutputVariable)
            base = baseOutputVariable
            _addExtraFieldsOutput!(terms)
        end

        #abstractType = eval(:baseTeste)
        #nameType = :Teste
        #mockType = :T
        #mockTypeConstraint = FloatingPoint
        #
        #exprCurlyInner = Expr(:<:,[mockType,mockTypeConstraint]...)
        #
        #typeExprCurly =Expr(:curly,nameType, exprCurlyInner)
        #fields = Array(Expr,0)
        #push!(fields,Expr(:(::),:value, mockType))
        #push!(fields,Expr(:(::),:value2, mockType))
        #fieldsExpr = Expr(:block,fields...)
        #innerType = Expr(:<:,[typeExprCurly,abstractType]...)
        #
        #typeExpr = Expr(:type,[true,innerType,fieldsExpr]...)
        #
        #hhh2 = Expr(:block,typeExpr)



        #type nameType <: #
        exprCurlyInner = Expr(:<:,[:T,FloatingPoint]...)
        typeExprCurly = Expr(:curly,[nameType,exprCurlyInner]...)
        typeExpr = Expr(:<:,[typeExprCurly,base]...)
        fieldsExpr = Expr(:block,terms...)
        newTypeVariable = Expr(:type,[true,typeExpr,fieldsExpr]...)
        #This will create the type in the memory
        (verbose) && print(newTypeVariable)
        (verbose) && print("\n")
        eval(newTypeVariable)
        (verbose) && print(nameType)
        variableSkeleton.typeFinal = eval(nameType)
        verbose && print("New type variable generated:")
        (verbose) && print(variableSkeleton.typeFinal)
        (verbose) && print("\n")
        #and now returns the newly created type
        return variableSkeleton.typeFinal
    end
