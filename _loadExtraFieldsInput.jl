function _loadExtraFieldsInput!(functionParenthesis,variableSkeleton)
    name = Expr(:quote,variableSkeleton.name)
    push!(functionParenthesis,name)
    push!(functionParenthesis,variableSkeleton.value)
    push!(functionParenthesis,variableSkeleton.maxValue)
    push!(functionParenthesis,variableSkeleton.minValue)
end
