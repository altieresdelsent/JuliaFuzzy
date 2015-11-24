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
    desiredFuzzyDeaccelerationSocial = EngineSkeleton{float}()
    desiredFuzzyDeaccelerationSocial.name = "socialDeacceleration"
    desiredFuzzyDeaccelerationSocial.inputVariables = InputVariable{float}[]
    desiredFuzzyDeaccelerationSocial.outputVariables = OutputVariable{float}[]
    desiredFuzzyDeaccelerationSocial.ruleBlocks = RuleBlock[]
    desiredFuzzyDeaccelerationSocial.conjunction = AlgebraicProduct()
    desiredFuzzyDeaccelerationSocial.disjunction = AlgebraicSum()
    desiredFuzzyDeaccelerationSocial.activation = Minimum()
    desiredFuzzyDeaccelerationSocial.accumulation = Maximum()
    desiredFuzzyDeaccelerationSocial.defuzzifier = FastCentroid{float}()

    Force = InputVariable{float}()
    Force.value = 0.000
    Force.name = :Force
    Force.maxValue = pi
    Force.minValue = -pi
    Force.terms = Term[]

    push!(Force.terms,Gaussian{float}(:ZERO, 0.0, 0.4,Terms.GaussianType_Left))
    push!(Force.terms,Gaussian{float}(:WEAK, 1.0, 0.4))
    push!(Force.terms,Gaussian{float}(:STRONG, 2.0, 0.4,Terms.GaussianType_Right))

    push!(desiredFuzzyDeaccelerationSocial.inputVariables,Force)

    Deacceleration = OutputVariable{float}()
    Deacceleration.name = :Deacceleration
    Deacceleration.maxValue = pi
    Deacceleration.minValue = -pi
    Deacceleration.terms = Term[]

    push!(Deacceleration.terms,Triangle{float}(:ZERO, -0.5, 0.5))
    push!(Deacceleration.terms,Triangle{float}(:WEAK, 0.0, 1.0))
    push!(Deacceleration.terms,Triangle{float}(:STRONG, 0.5, 1.5))

    push!(desiredFuzzyDeaccelerationSocial.outputVariables,Deacceleration)

    DesiredRuleBlock = RuleBlock(:DesiredRuleBlock)
    push!(desiredFuzzyDeaccelerationSocial.ruleBlocks,DesiredRuleBlock)

    rule1 = parseRule(desiredFuzzyDeaccelerationSocial,"if Force is ZERO then Deacceleration is ZERO")
    push!(DesiredRuleBlock.rules,rule1)

    rule2 = parseRule(desiredFuzzyDeaccelerationSocial,"if Force is WEAK then Deacceleration is WEAK")
    push!(DesiredRuleBlock.rules,rule2)

    rule3 = parseRule(desiredFuzzyDeaccelerationSocial,"if Force is STRONG then Deacceleration is STRONG")
    push!(DesiredRuleBlock.rules,rule3)

    configure(desiredFuzzyDeaccelerationSocial)

    functionTeste2 = buildFunction(desiredFuzzyDeaccelerationSocial)

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


