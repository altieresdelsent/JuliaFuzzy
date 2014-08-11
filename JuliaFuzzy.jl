module JuliaFuzzy
    include("norm/Norms.jl")
    include("term/Terms.jl")
    include("defuzzifier/Defuzzifiers.jl")
    include("variable/Variables.jl")
    include("rule/Rules.jl")

    using .Rules
    using .Variables
    using .Defuzzifiers
    using .Terms
    using .Norms

    using .Rules.Rule
    using .Rules.Expression
    using .Rules.Proposition
    using .Rules.Operator
    using .Rules.Antecedent
    using .Rules.Consequent
    using .Rules.And
    using .Rules.Or
    using .Rules.LogicalOperator
    using .Rules.RuleBlock

    using .Variables.Variable
    using .Variables.InputVariable
    using .Variables.OutputVariable
    using .Variables.DoesNotExistVariable
    using .Variables.getTerm

    using .Defuzzifiers.Defuzzifier

    using .Terms.Term
    using .Terms.DoesNotExistTerm

    using .Norms.SNorm
    using .Norms.TNorm

    abstract baseInputsVariables;
    abstract baseOutputsVariables;
    abstract baseRules;

    type EngineSkeleton{T <: FloatingPoint}
        inputVariables::Array{InputVariable{T},1}
        outputVariables::Array{OutputVariable{T},1}
        ruleBlocks::Array{RuleBlock,1}
        conjunction::TNorm
        disjunction::SNorm
        activation::TNorm
        accumulation::SNorm
        defuzzifier::Defuzzifier
        EngineSkeleton() = new()
    end

    type Engine
        inputVariables::baseInputsVariables
        outputVariables::baseOutputsVariables
        rules::baseRules
        defuzzifier::Defuzzifier;
        accumulation::SNorm;
        activation::TNorm;
        disjunction::SNorm;
        conjunction::TNorm;
    end

    function createEngine(engine::EngineSkeleton)
    end
    function _addInputVariables(engine::Engine,inputs)

        values = Expr(:block,[value1,value2,value3]...)
        x = Expr(:type,[true,:(finalInputVariable<:baseInputsVariables),values])
    return eval(x)
    end
    function _addOutputVariable(output)
    end
    function _addRules(rules)
    end
    function _configure()
    end

    value1 = Expr(:(::),:value1,:Int)
    value2 = Expr(:(::),:value2,:Int)
    value3 = Expr(:(::),:value3,:Int)
    values = Expr(:block,[value1,value2,value3]...)
    Expr(:type,[true,:(baseInputsVariables),values]...)

    include("_parseExpressions.jl")
    include("addInputVariable.jl")
    include("parseRule.jl")
    include("_parseProposition.jl")
    include("getVariable.jl")
    include("configure.jl")
    include("process.jl")

end
