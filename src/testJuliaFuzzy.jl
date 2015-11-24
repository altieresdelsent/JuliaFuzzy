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
using Gadfly
tic()


    desiredFuzzyFunctionVelocity = EngineSkeleton{float}()
    desiredFuzzyFunctionVelocity.name = "desiredFuzzyVelocity"
    desiredFuzzyFunctionVelocity.inputVariables = InputVariable{float}[]
    desiredFuzzyFunctionVelocity.outputVariables = OutputVariable{float}[]
    desiredFuzzyFunctionVelocity.ruleBlocks = RuleBlock[]
    desiredFuzzyFunctionVelocity.conjunction = AlgebraicProduct()
    desiredFuzzyFunctionVelocity.disjunction = AlgebraicSum()
    desiredFuzzyFunctionVelocity.activation = Minimum()
    desiredFuzzyFunctionVelocity.accumulation = Maximum()
    desiredFuzzyFunctionVelocity.defuzzifier = FastCentroid{float}()

    VelocityDifference = InputVariable{float}()
    VelocityDifference.value = 0.000
    VelocityDifference.name = :VelocityDifference
    VelocityDifference.maxValue = 10.0
    VelocityDifference.minValue = -10.0
    VelocityDifference.terms = Term[]

    push!(VelocityDifference.terms,Gaussian{float}(:VERYSLOW, -2.0, 0.4,Terms.GaussianType_Left))
    push!(VelocityDifference.terms,Gaussian{float}(:SLOW, -1.0, 0.4))
    push!(VelocityDifference.terms,Gaussian{float}(:FINE, 0.0, 0.4))
    push!(VelocityDifference.terms,Gaussian{float}(:FAST, 1.0, 0.4))
    push!(VelocityDifference.terms,Gaussian{float}(:VERYFAST, 2.0, 0.4,Terms.GaussianType_Right))

    #plotVariable(VelocityDifference)

    push!(desiredFuzzyFunctionVelocity.inputVariables,VelocityDifference)

    Force = OutputVariable{float}()
    Force.name = :Force
    Force.maxValue = 4.0
    Force.minValue = -4.0
    Force.terms = Term[]

    push!(Force.terms,Triangle{float}(:STRONGNEGATIVE, -3.0, -1.0))
    push!(Force.terms,Triangle{float}(:NEGATIVE, -2.0, 0.0))
    push!(Force.terms,Triangle{float}(:ZERO, -1.0, 1.0))
    push!(Force.terms,Triangle{float}(:POSITIVE, 0.0, 2.0))
    push!(Force.terms,Triangle{float}(:STRONGPOSITIVE, 1.0, 3.0))

    push!(desiredFuzzyFunctionVelocity.outputVariables,Force)

    DesiredRuleBlock = RuleBlock(:DesiredRuleBlock)
    push!(desiredFuzzyFunctionVelocity.ruleBlocks,DesiredRuleBlock)

    rule1 = parseRule(desiredFuzzyFunctionVelocity,"if VelocityDifference is VERYSLOW then Force is STRONGPOSITIVE")
    push!(DesiredRuleBlock.rules,rule1)

    rule2 = parseRule(desiredFuzzyFunctionVelocity,"if VelocityDifference is SLOW then Force is POSITIVE")
    push!(DesiredRuleBlock.rules,rule2)

    rule3 = parseRule(desiredFuzzyFunctionVelocity,"if VelocityDifference is FINE then Force is ZERO")
    push!(DesiredRuleBlock.rules,rule3)

    rule4 = parseRule(desiredFuzzyFunctionVelocity,"if VelocityDifference is FAST then Force is NEGATIVE")
    push!(DesiredRuleBlock.rules,rule4)

    rule5 = parseRule(desiredFuzzyFunctionVelocity,"if VelocityDifference is VERYFAST then Force is STRONGNEGATIVE")
    push!(DesiredRuleBlock.rules,rule5)

    configure(desiredFuzzyFunctionVelocity)

    functionTeste = eval(buildFunction(desiredFuzzyFunctionVelocity))
    plot(functionTeste,-2,2)

    #print(functionTeste)

    #testeLento = eval(functionTeste)
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


