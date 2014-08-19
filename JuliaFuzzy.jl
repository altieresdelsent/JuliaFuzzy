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
    using .Variables.baseInputVariable
    using .Variables.baseOutputVariable
    using .Variables.baseInputVariables
    using .Variables.baseOutputVariables

    using .Defuzzifiers.Defuzzifier

    using .Terms.Term
    using .Terms.Accumulated
    using .Terms.DoesNotExistTerm

    using .Norms.SNorm
    using .Norms.TNorm

    abstract Engine;

    type EngineSkeleton{T <: FloatingPoint} <: Engine
        inputVariables::Array{InputVariable{T},1}
        outputVariables::Array{OutputVariable{T},1}
        ruleBlocks::Array{RuleBlock,1}
        conjunction::TNorm
        disjunction::SNorm
        activation::TNorm
        accumulation::SNorm
        defuzzifier::Defuzzifier
        inputsType::DataType
        outputsType::DataType
        EngineSkeleton() = new()
    end

    function _generateDefuzzify()

    end

    function _generateProcess()

    end
    function _addRules(rules)
    end
    function _configure()
    end

    #value1 = Expr(:(::),:value1,:Int)
    #value2 = Expr(:(::),:value2,:Int)
    #value3 = Expr(:(::),:value3,:Int)
    #values = Expr(:block,[value1,value2,value3]...)
    #Expr(:type,[true,:(baseInputsVariables),values]...)


    include("addInputVariable.jl")
    include("parseRule.jl")
    include("getVariable.jl")
    include("configure.jl")
    include("process.jl")

    include("_addExtraFieldsInput.jl")
    include("_addExtraFieldsOutput.jl")

    include("_generateEngine.jl")
    include("_generateTerms.jl")
    include("_generateVariable.jl")
    include("_generateVariables.jl")

    include("_instanceEngine.jl")
    include("_instanceVariable.jl")
    include("_instanceVariables.jl")

    include("_loadExtraFieldsInput.jl")
    include("_loadExtraFieldsOutput.jl")

    include("_parseExpressions.jl")
    include("_parseProposition.jl")

    include("_updateRulesBlocks.jl")
    include("buildEngine.jl")

end
