function toArrayExpression(firstExpression::Expression, finalLength)
    array = Array(Operator,finalLength-1)
    currentExpression = firstExpression
    for i in 1:finalLength
        if isa(currentExpression,Operator)
            array[i] = currentExpression;
            currentExpression = currentExpression.right
        end
    end
    reverse!(array)
    return (currentExpression, array)
end
