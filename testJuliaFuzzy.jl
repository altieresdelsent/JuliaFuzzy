include("JuliaFuzzy.jl")

using JuliaFuzzy.EngineSkeleton
using JuliaFuzzy.Norms.TNorm
using JuliaFuzzy.Norms.Norm
using JuliaFuzzy.Norms.SNorm
using JuliaFuzzy.Norms.TNorms.Minimum
using JuliaFuzzy.Norms.SNorms.Maximum
using JuliaFuzzy.Norms.TNorms.AlgebraicProduct
using JuliaFuzzy.Norms.SNorms.AlgebraicSum
using JuliaFuzzy.Defuzzifiers.Centroid
using JuliaFuzzy.Rules.Rule
using JuliaFuzzy.Rules.RuleBlock
using JuliaFuzzy.Variables.InputVariable
using JuliaFuzzy.Variables.OutputVariable
using JuliaFuzzy.Terms.Constant
using JuliaFuzzy.Terms.Triangle
using JuliaFuzzy.Terms.Gaussian
using JuliaFuzzy.Terms.Term

float = Float64
resolution = 200.0

engineSkeleton = JuliaFuzzy.EngineSkeleton{float}()
engineSkeleton.inputVariables = InputVariable{float}[]
engineSkeleton.outputVariables = OutputVariable{float}[]
engineSkeleton.ruleBlocks = RuleBlock[]
engineSkeleton.conjunction = Minimum()
engineSkeleton.disjunction = Maximum()
engineSkeleton.activation = AlgebraicProduct()
engineSkeleton.accumulation = AlgebraicSum()
engineSkeleton.defuzzifier = Centroid{float}(resolution)


Ambient = InputVariable{float}()
Ambient.value = 0.000
Ambient.name = :Ambient
Ambient.maxValue = 1.0
Ambient.minValue = 0.0
Ambient.terms = Term[]

push!(Ambient.terms,Gaussian{float}(:DARK, 0.250, 0.125));
push!(Ambient.terms,Gaussian{float}(:MEDIUM, 0.500, 0.125));
push!(Ambient.terms,Gaussian{float}(:BRIGHT, 0.750, 0.125));

push!(engineSkeleton.inputVariables,Ambient)

Person = InputVariable{float}()
Person.value = 0.000
Person.name = :Person
Person.maxValue = 1.0
Person.minValue = 0.0
Person.terms = Term[]

push!(Person.terms,Gaussian{float}(:NICE, 0.250, 0.125));
push!(Person.terms,Gaussian{float}(:SOSO, 0.500, 0.125));
push!(Person.terms,Gaussian{float}(:IDIOT, 0.750, 0.125));

push!(engineSkeleton.inputVariables,Person)

Sound = InputVariable{float}()
Sound.value = 0.000
Sound.name = :Sound
Sound.maxValue = 1.0
Sound.minValue = 0.0
Sound.terms = Term[]

push!(Sound.terms,Gaussian{float}(:LOUD, 0.250, 0.125));
push!(Sound.terms,Gaussian{float}(:GOOD, 0.500, 0.125));
push!(Sound.terms,Gaussian{float}(:QUIET, 0.750, 0.125));

push!(engineSkeleton.inputVariables,Sound)


Power = OutputVariable{float}()
Power.name = :Power
Power.maxValue = 2.0
Power.minValue = 0.0
Power.terms = Term[]

push!(Power.terms,Triangle{float}(:LOW,0.000, 1.000));
push!(Power.terms,Triangle{float}(:MEDIUM, 0.500, 1.500));
push!(Power.terms,Triangle{float}(:HIGH, 1.000, 2.000));

push!(engineSkeleton.outputVariables,Power)

PowerController = RuleBlock(:PowerController)
push!(engineSkeleton.ruleBlocks,PowerController)

rule1 = JuliaFuzzy.parseRule(engineSkeleton,"if Ambient is DARK and Person is NICE and Sound is LOUD then Power is HIGH")
push!(PowerController.rules,rule1)

rule2 = JuliaFuzzy.parseRule(engineSkeleton,"if Ambient is MEDIUM and Person is SOSO and Sound is GOOD then Power is MEDIUM")
push!(PowerController.rules,rule2)

rule3 = JuliaFuzzy.parseRule(engineSkeleton,"if Ambient is BRIGHT and Person is IDIOT and Sound is QUIET then Power is LOW")
push!(PowerController.rules,rule3)

JuliaFuzzy.configure(engineSkeleton)

for i in 1:48
        light = Ambient.minValue + i * ((Ambient.maxValue-Ambient.minValue) / 50);
        Ambient.value = light;
        Person.value = light;
        Sound.value = light;

        print("Light:");
        print("$light");
        print("\n")

        JuliaFuzzy.process(engineSkeleton)

        finalValue = JuliaFuzzy.Variables.defuzzify(Power)


        print("power:");
        print("$finalValue");
        print("\n");

end



