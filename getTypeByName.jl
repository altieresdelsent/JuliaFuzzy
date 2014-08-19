function getTypeByName(tType::DataType,name)
    sName = symbol(name)
    namesType = names(tType)
    for nameType in zip(tType.types,tType.names)
        if nameType[2] == sName
            return nameType[1]
    end
end
