
    abstract baseTeste
    hhh = quote
        type Teste{T <: FloatingPoint} <: baseTeste
            value::T
            value2::T
            name::Symbol
            termsActivation::Dict{Symbol,T}
        end
    end
    ggg = quote
    Teste(1.0,2.0,:name)
    end
    splice!(ggg.args,1)

    splice!(hhh.args,1)
    splice!(hhh.args[1].args[3].args,1)
    splice!(hhh.args[1].args[3].args,2)

    abstractType = eval(:baseTeste)
    TypeCreating = :Teste
    mockType = :T
    mockTypeConstraint = FloatingPoint

    exprCurlyInner = Expr(:<:,[mockType,mockTypeConstraint]...)

    finalType =Expr(:curly,TypeCreating, exprCurlyInner)
    fields = Array(Expr,0)
    push!(fields,Expr(:(::),:value, mockType))
    push!(fields,Expr(:(::),:value2, mockType))
    fieldsExpr = Expr(:block,fields...)
    innerType = Expr(:<:,[finalType,abstractType]...)

    typeExpr = Expr(:type,[true,innerType,fieldsExpr]...)

    hhh2 = Expr(:block,typeExpr)

    x = quote
        y = Teste(1,2)
    end


    callfunction = Expr(:call,[:Teste,1,2]...)
    inner = Expr(:(=),[:y,callfunction]...)
    b = Expr(:block,[inner]...)
    function hhahaa(b)
        eval(b)
    end

