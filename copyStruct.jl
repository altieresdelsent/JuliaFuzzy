function copyStruct(varType,newName)
    namesType = names(varType)
    counter = 0;
    arrayInnerStruct = Array(Expr,length(namesType))
    for nameType in namesType
        counter = counter + 1
        typeVariable = varType.types[counter]
        arrayInnerStruct[counter] = Expr(:(::),nameType,typeVariable)
    end
    innerStruct = Expr(:block,arrayInnerStruct...)
    Expr(:type,[true,symbol(newName),innerStruct]...)
end
