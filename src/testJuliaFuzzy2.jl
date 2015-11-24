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
    desiredFuzzyFunctionAngle = EngineSkeleton{float}()
    desiredFuzzyFunctionAngle.name = "desiredFuzzyFunctionAngleAngle"
    desiredFuzzyFunctionAngle.inputVariables = InputVariable{float}[]
    desiredFuzzyFunctionAngle.outputVariables = OutputVariable{float}[]
    desiredFuzzyFunctionAngle.ruleBlocks = RuleBlock[]
    desiredFuzzyFunctionAngle.conjunction = AlgebraicProduct()
    desiredFuzzyFunctionAngle.disjunction = AlgebraicSum()
    desiredFuzzyFunctionAngle.activation = Minimum()
    desiredFuzzyFunctionAngle.accumulation = Maximum()
    desiredFuzzyFunctionAngle.defuzzifier = FastCentroid{float}()

    DirectionAngle = InputVariable{float}()
    DirectionAngle.value = 0.000
    DirectionAngle.name = :DirectionAngle
    DirectionAngle.maxValue = pi
    DirectionAngle.minValue = -pi
    DirectionAngle.terms = Term[]

    push!(DirectionAngle.terms,Gaussian{float}(:BACKLEFT, -pi, pi*0.2))
    push!(DirectionAngle.terms,Gaussian{float}(:FRONTLEFT, -pi*0.5, pi*0.2))
    push!(DirectionAngle.terms,Gaussian{float}(:BACKRIGHT, pi, pi*0.2))
    push!(DirectionAngle.terms,Gaussian{float}(:FRONT, 0.0, pi*0.2))
    push!(DirectionAngle.terms,Gaussian{float}(:FRONTRIGHT, pi*0.5, pi*0.2))
    push!(DirectionAngle.terms,Gaussian{float}(:BACKRIGHT, pi, pi*0.2))



    push!(desiredFuzzyFunctionAngle.inputVariables,DirectionAngle)

    AngleTurn = OutputVariable{float}()
    AngleTurn.name = :AngleTurn
    AngleTurn.maxValue = pi
    AngleTurn.minValue = -pi
    AngleTurn.terms = Term[]

    push!(AngleTurn.terms,Triangle{float}(:STRONGLEFT, -1.5*pi, -0.5*pi))
    push!(AngleTurn.terms,Triangle{float}(:WEAKLEFT, -pi*1.0, 0.0))
    push!(AngleTurn.terms,Triangle{float}(:CENTER, -pi*0.5, pi*0.5))
    push!(AngleTurn.terms,Triangle{float}(:WEAKRIGHT, 0.0, pi*1.0))
    push!(AngleTurn.terms,Triangle{float}(:STRONGRIGHT, 0.5*pi, 1.5*pi))

    push!(desiredFuzzyFunctionAngle.outputVariables,AngleTurn)

    DesiredRuleBlock = RuleBlock(:DesiredRuleBlock)
    push!(desiredFuzzyFunctionAngle.ruleBlocks,DesiredRuleBlock)

    rule1 = parseRule(desiredFuzzyFunctionAngle,"if DirectionAngle is BACKLEFT then AngleTurn is STRONGRIGHT")
    push!(DesiredRuleBlock.rules,rule1)

    rule2 = parseRule(desiredFuzzyFunctionAngle,"if DirectionAngle is FRONTLEFT then AngleTurn is WEAKRIGHT")
    push!(DesiredRuleBlock.rules,rule2)

    rule3 = parseRule(desiredFuzzyFunctionAngle,"if DirectionAngle is FRONT then AngleTurn is CENTER")
    push!(DesiredRuleBlock.rules,rule3)

    rule4 = parseRule(desiredFuzzyFunctionAngle,"if DirectionAngle is FRONTRIGHT then AngleTurn is WEAKLEFT")
    push!(DesiredRuleBlock.rules,rule4)

    rule5 = parseRule(desiredFuzzyFunctionAngle,"if DirectionAngle is BACKRIGHT then AngleTurn is STRONGLEFT")
    push!(DesiredRuleBlock.rules,rule5)

    configure(desiredFuzzyFunctionAngle)

    functionTeste2 = buildFunction(desiredFuzzyFunctionAngle)

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


