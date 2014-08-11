
module Rules
    using ..Variables.Variable
    using ..Terms.Term
    using ..Norms.TNorm
    using ..Norms.SNorm

    abstract Expression

    abstract LogicalOperator



    type Proposition <: Expression
        variable::Variable
        term::Term
    end

    type Operator <: Expression
       left::Expression
       operator::LogicalOperator
       right::Expression
    end

    type Antecedent
        head::Proposition
        tail::Array{Operator,1}
    end

    type Consequent
        head::Proposition
        tail::Array{Operator,1}
    end

    type Rule
        antecedent::Antecedent
        consequent::Consequent
    end

    type RuleBlock
        name::Symbol;
        rules::Array{Rule,1}
        conjunction::TNorm;
        disjunction::SNorm;
        activation::TNorm;

        function RuleBlock(name::Symbol)
            return new(name,Rule[])
        end
    end

    type Or <: LogicalOperator
    end;

    type And <: LogicalOperator
    end

    type Not <: LogicalOperator
    end

    type NoOperator <: LogicalOperator
    end

    include("toArrayExpression.jl")
    include("cleanFuzzyOutput.jl")
    include("activate.jl")
    include("activationDegree.jl")
    include("modify.jl")



end
