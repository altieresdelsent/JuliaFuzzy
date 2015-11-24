module JuliaFuzzy
	isdefined(:LinearAlgebra) || include("linearAlgebra/LinearAlgebra.jl")
    isdefined(:Norms) || include("norm/Norms.jl")
    isdefined(:Terms) || include("term/Terms.jl")
    isdefined(:Defuzzifiers) || include("defuzzifier/Defuzzifiers.jl")
    isdefined(:Variables) || include("variable/Variables.jl")
    isdefined(:Rules) || include("rule/Rules.jl")
    #using Debug
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
    using .Terms.Activated
    using .Terms.DoesNotMatterTerm
    using .Terms.DoesNotExistTerm

    using .Norms.SNorm
    using .Norms.TNorm

    export Engine, EngineSkeleton

    abstract Engine;

    type EngineSkeleton{T <: FloatingPoint} <: Engine
        name::Symbol
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
        EngineSkeleton(name) = new(name)
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


    isdefined(:addInputVariable) || include("addInputVariable.jl")
    isdefined(:parseRule) || include("parseRule.jl")
    isdefined(:getVariable) || include("getVariable.jl")
    isdefined(:configure) || include("configure.jl")
    isdefined(:firstConfiguration) || include("firstConfiguration.jl")
    isdefined(:process) || include("process.jl")

    isdefined(:_addExtraFieldsInput!) || include("_addExtraFieldsInput.jl")
    isdefined(:_addExtraFieldsOutput!) || include("_addExtraFieldsOutput.jl")

    isdefined(:_generateEngine) || include("_generateEngine.jl")
    isdefined(:_generateTerms) || include("_generateTerms.jl")
    isdefined(:_generateVariable) || include("_generateVariable.jl")
    isdefined(:_generateVariables) || include("_generateVariables.jl")

    isdefined(:_instanceEngine) || include("_instanceEngine.jl")
    isdefined(:_instanceVariable) || include("_instanceVariable.jl")
    isdefined(:_instanceVariables) || include("_instanceVariables.jl")

    isdefined(:_loadExtraFieldsInput!) || include("_loadExtraFieldsInput.jl")
    isdefined(:_loadExtraFieldsOutput!) || include("_loadExtraFieldsOutput.jl")

    isdefined(:_parseExpressions) || include("_parseExpressions.jl")
    isdefined(:_parseProposition) || include("_parseProposition.jl")

    isdefined(:_updateRulesBlocks!) || include("_updateRulesBlocks.jl")
    isdefined(:buildEngine) || include("buildEngine.jl")
    isdefined(:buildFunction) || include("buildFunction.jl")
    isdefined(:plotVariable) || include("plotVariable.jl")

end
