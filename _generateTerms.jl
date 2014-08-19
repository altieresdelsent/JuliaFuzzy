function _generateTerms(termsSkeleton)
    terms = Array(Expr,length(termsSkeleton))
    contador = 0
    for termSkeleton in termsSkeleton
        contador = contador + 1
        terms[contador] =  Expr(:(::),termSkeleton.name,typeof(termSkeleton))
    end
    return terms;
end
