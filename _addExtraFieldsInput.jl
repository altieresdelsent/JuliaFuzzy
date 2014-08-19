function _addExtraFieldsInput!(terms)
    push!(terms,Expr(:(::),:name,Symbol))
    push!(terms,Expr(:(::),:value,:T))
    push!(terms,Expr(:(::),:maxValue,:T))
    push!(terms,Expr(:(::),:minValue,:T))
end
