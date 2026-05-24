
module Rules
    #using Debug 
    
    using ..Variables: Variable
    using ..Terms: Term
    using ..Norms: TNorm
    using ..Norms: SNorm

    abstract type Expression end

    abstract type LogicalOperator end



    mutable struct Proposition <: Expression
        variable::Variable
        term::Term
    end

    mutable struct Operator <: Expression
       left::Expression
       operator::LogicalOperator
       right::Expression
    end

    mutable struct Antecedent
        head::Proposition
        tail::Array{Operator,1}
    end

    mutable struct Consequent
        head::Proposition
        tail::Array{Operator,1}
    end

    mutable struct Rule
        antecedent::Antecedent
        consequent::Consequent
    end

    mutable struct RuleBlock
        name::Symbol;
        rules::Array{Rule,1}
        conjunction::TNorm;
        disjunction::SNorm;
        activation::TNorm;

        function RuleBlock(name::Symbol)
            this = new()
            this.name = name
            this.rules = Rule[]
            return this
        end
    end

    mutable struct Or <: LogicalOperator
    end

    mutable struct And <: LogicalOperator
    end

    mutable struct Not <: LogicalOperator
    end

    mutable struct NoOperator <: LogicalOperator
    end

    isdefined(@__MODULE__, :toArrayExpression) || include("toArrayExpression.jl")
    isdefined(@__MODULE__, :cleanFuzzyOutput) || include("cleanFuzzyOutput.jl")
    isdefined(@__MODULE__, :activate) || include("activate.jl")
    isdefined(@__MODULE__, :activationDegree) || include("activationDegree.jl")
    isdefined(@__MODULE__, :modify) || include("modify.jl")



end
