module JuliaFuzzy
    isdefined(@__MODULE__, :Norms) || include("norm/Norms.jl")
    isdefined(@__MODULE__, :Terms) || include("term/Terms.jl")
    isdefined(@__MODULE__, :Defuzzifiers) || include("defuzzifier/Defuzzifiers.jl")
    isdefined(@__MODULE__, :Variables) || include("variable/Variables.jl")
    isdefined(@__MODULE__, :Rules) || include("rule/Rules.jl")
    #using Debug
    using .Rules
    using .Variables
    using .Defuzzifiers
    using .Terms
    using .Norms

    using LinearFunc

    using .Rules: Rule
    using .Rules: Expression
    using .Rules: Proposition
    using .Rules: Operator
    using .Rules: Antecedent
    using .Rules: Consequent
    using .Rules: And
    using .Rules: Or
    using .Rules: LogicalOperator
    using .Rules: RuleBlock

    using .Variables: Variable
    using .Variables: InputVariable
    using .Variables: OutputVariable
    using .Variables: DoesNotExistVariable
    using .Variables: getTerm
    using .Variables: baseInputVariable
    using .Variables: baseOutputVariable
    using .Variables: baseInputVariables
    using .Variables: baseOutputVariables

    using .Defuzzifiers: Defuzzifier

    using .Terms: Term
    using .Terms: Accumulated
    using .Terms: Activated
    using .Terms: DoesNotMatterTerm
    using .Terms: DoesNotExistTerm

    using .Norms: SNorm
    using .Norms: TNorm

    using Random

    export Engine, EngineSkeleton

    abstract type Engine end

    mutable struct EngineSkeleton{T <: AbstractFloat} <: Engine
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
        EngineSkeleton{T}() where T <: AbstractFloat = new{T}()
        EngineSkeleton{T}(name) where T <: AbstractFloat = new{T}(name)
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


    isdefined(@__MODULE__, :addInputVariable) || include("addInputVariable.jl")
    isdefined(@__MODULE__, :parseRule) || include("parseRule.jl")
    isdefined(@__MODULE__, :getVariable) || include("getVariable.jl")
    isdefined(@__MODULE__, :configure) || include("configure.jl")
    isdefined(@__MODULE__, :firstConfiguration) || include("firstConfiguration.jl")
    isdefined(@__MODULE__, :process) || include("process.jl")

    isdefined(@__MODULE__, :_addExtraFieldsInput!) || include("_addExtraFieldsInput.jl")
    isdefined(@__MODULE__, :_addExtraFieldsOutput!) || include("_addExtraFieldsOutput.jl")

    isdefined(@__MODULE__, :_generateEngine) || include("_generateEngine.jl")
    isdefined(@__MODULE__, :_generateTerms) || include("_generateTerms.jl")
    isdefined(@__MODULE__, :_generateVariable) || include("_generateVariable.jl")
    isdefined(@__MODULE__, :_generateVariables) || include("_generateVariables.jl")

    isdefined(@__MODULE__, :_instanceEngine) || include("_instanceEngine.jl")
    isdefined(@__MODULE__, :_instanceVariable) || include("_instanceVariable.jl")
    isdefined(@__MODULE__, :_instanceVariables) || include("_instanceVariables.jl")

    isdefined(@__MODULE__, :_loadExtraFieldsInput!) || include("_loadExtraFieldsInput.jl")
    isdefined(@__MODULE__, :_loadExtraFieldsOutput!) || include("_loadExtraFieldsOutput.jl")

    isdefined(@__MODULE__, :_parseExpressions) || include("_parseExpressions.jl")
    isdefined(@__MODULE__, :_parseProposition) || include("_parseProposition.jl")

    isdefined(@__MODULE__, :_updateRulesBlocks!) || include("_updateRulesBlocks.jl")
    isdefined(@__MODULE__, :buildEngine) || include("buildEngine.jl")
    try
        isdefined(@__MODULE__, :buildFunction) || include("buildFunction.jl")
    catch e
        @warn "buildFunction.jl could not be loaded (optional code generation): $e"
    end
    try
        isdefined(@__MODULE__, :plotVariable) || include("plotVariable.jl")
    catch e
        @warn "plotVariable.jl could not be loaded (optional plotting): $e"
    end

end
