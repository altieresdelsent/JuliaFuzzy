cd("/home/altieres/Copy/Mestrado/Dissertacao/materialJuliaLang/evacuation/JuliaFuzzy")
using JuliaFuzzy

using JuliaFuzzy.EngineSkeleton
using JuliaFuzzy.parseRule
using JuliaFuzzy.configure
using JuliaFuzzy.buildFunction
using JuliaFuzzy.Norms.TNorm
using JuliaFuzzy.Norms.Norm
using JuliaFuzzy.Norms.SNorm
using JuliaFuzzy.Norms.TNorms.Minimum
using JuliaFuzzy.Norms.SNorms.Maximum
using JuliaFuzzy.Norms.TNorms.AlgebraicProduct
using JuliaFuzzy.Norms.SNorms.AlgebraicSum
using JuliaFuzzy.Defuzzifiers.FastCentroid
using JuliaFuzzy.Rules.Rule
using JuliaFuzzy.Rules.RuleBlock
using JuliaFuzzy.Variables.InputVariable
using JuliaFuzzy.Variables.OutputVariable
using JuliaFuzzy.Terms.Constant
using JuliaFuzzy.Terms.Triangle
using JuliaFuzzy.Terms.Gaussian
using JuliaFuzzy.Terms.Sigmoid
using JuliaFuzzy.Terms.Term
using JuliaFuzzy.Terms

using JuliaFuzzy.LinearAlgebra
using JuliaFuzzy.LinearAlgebra.LinearFunc
using JuliaFuzzy.LinearAlgebra.solveFast
using JuliaFuzzy.plotVariable
using Debug

const float = Float64
const resolution = 100.0

tic()

#for i in 1:1000
    desiredFuzzyDirectionSocial = EngineSkeleton{float}()
    desiredFuzzyDirectionSocial.name = "desiredFuzzyFunctionAngleAngle"
    desiredFuzzyDirectionSocial.inputVariables = InputVariable{float}[]
    desiredFuzzyDirectionSocial.outputVariables = OutputVariable{float}[]
    desiredFuzzyDirectionSocial.ruleBlocks = RuleBlock[]
    desiredFuzzyDirectionSocial.conjunction = AlgebraicProduct()
    desiredFuzzyDirectionSocial.disjunction = AlgebraicSum()
    desiredFuzzyDirectionSocial.activation = Minimum()
    desiredFuzzyDirectionSocial.accumulation = Maximum()
    desiredFuzzyDirectionSocial.defuzzifier = FastCentroid{float}()

    RelativeVelocity = InputVariable{float}()
    RelativeVelocity.value = 0.000
    RelativeVelocity.name = :RelativeVelocity
    RelativeVelocity.maxValue = pi
    RelativeVelocity.minValue = -pi
    RelativeVelocity.terms = Term[]

    push!(RelativeVelocity.terms,Gaussian{float}(:ZERO, 0.0, 0.4,Terms.GaussianType_Left))
    push!(RelativeVelocity.terms,Gaussian{float}(:WEAK, 1.0, 0.4))
    push!(RelativeVelocity.terms,Gaussian{float}(:STRONG, 2.0, 0.4,Terms.GaussianType_Right))

    push!(desiredFuzzyDirectionSocial.inputVariables,RelativeVelocity)

    AngleTurn = OutputVariable{float}()
    AngleTurn.name = :AngleTurn
    AngleTurn.maxValue = pi
    AngleTurn.minValue = -pi
    AngleTurn.terms = Term[]

    push!(AngleTurn.terms,Triangle{float}(:ZERO, -0.5, 0.5))
    push!(AngleTurn.terms,Triangle{float}(:WEAK, 0.0, 1.0))
    push!(AngleTurn.terms,Triangle{float}(:STRONG, 0.5, 1.5))

    push!(desiredFuzzyDirectionSocial.outputVariables,AngleTurn)

    DesiredRuleBlock = RuleBlock(:DesiredRuleBlock)
    push!(desiredFuzzyDirectionSocial.ruleBlocks,DesiredRuleBlock)

    rule1 = parseRule(desiredFuzzyDirectionSocial,"if RelativeVelocity is ZERO then AngleTurn is ZERO")
    push!(DesiredRuleBlock.rules,rule1)

    rule2 = parseRule(desiredFuzzyDirectionSocial,"if RelativeVelocity is WEAK then AngleTurn is WEAK")
    push!(DesiredRuleBlock.rules,rule2)

    rule3 = parseRule(desiredFuzzyDirectionSocial,"if RelativeVelocity is STRONG then AngleTurn is STRONG")
    push!(DesiredRuleBlock.rules,rule3)

    configure(desiredFuzzyDirectionSocial)

    functionTeste2 = buildFunction(desiredFuzzyDirectionSocial)

    #print(functionTeste2)

    testeLento2 = eval(functionTeste2)
#end
#print(functionTeste)
toc()

#=
print(testeLento(0.0,0.0))
iterations = 1000000
angle = rand(iterations)*pi*0.1
velocity = rand(iterations)+1.5
soma = 0.0
c = testeLento(rand()*10,rand()*pi)
print(c)
d = testeLento(rand()*10,rand()*pi)
toc()
print("-------------------------------\n")

tic()
soma = 0.0
for i in 1:iterations
    (a,b) = testeLento(velocity[i],angle[i])
    soma = soma + a + b
end
toc()

tic()
soma = 0.0
ttttt = (v,a,f) -> v + a
for i in 1:iterations
    b = ttttt(velocity[i],angle[i],testeLento)
end
toc()
rand()
#==#
#==#
=#


