isdefined(:LinearAlgebra) || include("linearAlgebra/LinearAlgebra.jl")
isdefined(:Norms) || include("norm/Norms.jl")
isdefined(:Terms) || include("term/Terms.jl")
isdefined(:Defuzzifiers) || include("defuzzifier/Defuzzifiers.jl")
isdefined(:Variables) || include("variable/Variables.jl")
isdefined(:Rules) || include("rule/Rules.jl")

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

using .Terms
using .Terms.Term
using .Terms.Accumulated
using .Terms.Activated
using .Terms.DoesNotMatterTerm
using .Terms.DoesNotExistTerm

using .Norms.SNorm
using .Norms.TNorm

using .Terms.Gaussian
using .Terms.Sigmoid
using .Terms.Triangular

using .Norms.SNorm
using .Norms.TNorm

using .Norms.SNorms.AlgebraicSum
using .Norms.SNorms.BoundedSum
using .Norms.SNorms.DrasticSum
using .Norms.SNorms.EinsteinSum
using .Norms.SNorms.HamacherSum
using .Norms.SNorms.NormalizedSum
using .Norms.SNorms.Maximum

using .Norms.TNorms.AlgebraicProduct
using .Norms.TNorms.BoundedDifference
using .Norms.TNorms.DrasticProduct
using .Norms.TNorms.EinsteinProduct
using .Norms.TNorms.HamacherProduct
using .Norms.TNorms.Minimum

using Debug
function buildFunction(engineSkeleton)
    function createSigmoid(inflection, slope, nameVariable,returnVariable)

        sigmoidal = (quote
            $returnVariable = 1.0 / (1.0 + exp( $(-slope) * ($nameVariable - $inflection)))
        end)
        return sigmoidal.args
    end
    function createGaussian(mean, sd,nameVariable,returnVariable, typeGaussian)
        twoSdSquared = 2* sd * sd
        if typeGaussian == Terms.GaussianType_Left
            gaussian = (quote
                quotient = $nameVariable + $(-mean)
                $returnVariable = (quotient <= 0.0)?1.0:exp(-(quotient * quotient) / $twoSdSquared)
            end)
        elseif typeGaussian == Terms.GaussianType_Normal
            gaussian = (quote
                quotient = $nameVariable + $(-mean)
                $returnVariable = exp(-(quotient * quotient) / $twoSdSquared)
            end)
        elseif typeGaussian == Terms.GaussianType_Right
            gaussian = (quote
                quotient = $nameVariable + $(-mean)
                $returnVariable = (quotient >= 0.0)?1.0:exp(-(quotient * quotient) / $twoSdSquared)
            end)
        end
        return gaussian.args
    end

    function createTriangle(a,c,nameVariable,returnVariable)
        minA = min(a,c)
        maxC = max(a,c)

        b = minA + ((maxC - minA) / 2)
        slopeA = 1 / b - minA
        slopeC = 1 / maxC - b
        triangular = (quote
            if ($nameVariable <= $minA) || ($nameVariable >= $c)
                $returnVariable = 0.0;
            elseif $nameVariable == $b
                $returnVariable = 1.0;
            elseif $nameVariable < $b
                $returnVariable = ($nameVariable - $minA) * $slopeA;
            else
                $returnVariable = ($maxC - $nameVariable) * $slopeC;
            end
        end)
        return triangular.args
    end
    function createFuzzifier(inputVariable)
        nameInput = inputVariable.name
        terms = inputVariable.terms
        lines = Array(Any,0)
        for term in terms
            ss = "$(string(inputVariable.name))_$(string(term.name))"
            nameTerm = symbol(ss)
            if typeof(term) <: Gaussian
                lines = [lines, createGaussian(term.mean,term.standardDeviation,nameInput,nameTerm,term.gaussType)]
            elseif typeof(term) <: Triangle
                lines = [lines, createTriangle(term.vertexA,term.vertexC,nameInput,nameTerm)]
            elseif typeof(term) <: Sigmoid
                lines = [lines, createSigmoid(term.inflection,term.slope,nameInput,nameTerm)]
            end
            #@bp
        end

        return lines
    end
    function generateFuzzifier(inputVariables)
        lines = Array(Any,0)
        for inputVariable in inputVariables
            lines = [lines, createFuzzifier(inputVariable)]
        end
        return lines
    end
    function createInference(rule, ruleNumber)
        function compute(tType::Minimum, aName, bName, returnVariable)
            (quote
                $returnVariable = min($aName, $bName)
            end).args
        end
        function compute(tType::HamacherProduct, aName, bName, returnVariable)
            (quote
                $returnVariable = ($aName * $bName) / ($aName + $bName - $aName * $bName)
            end).args
        end

        function compute(tType::EinsteinProduct, aName, bName, returnVariable)
            (quote
                $returnVariable = ($aName * $bName) / (2 - ($aName + $bName - $aName * $bName))
            end).args
        end

        function compute(tType::DrasticProduct, aName,bName, returnVariable)
            (quote
                if max($aName, $bName) == 1.0
                    $returnVariable = min($aName, $bName)
                end
                $returnVariable = 0.0
            end).args
        end

        function compute(tType::BoundedDifference,aName ,bName, returnVariable)
            quote
                $returnVariable = max(0.0, $aName + $bName - 1)
            end
        end

        function compute(tType::AlgebraicProduct, aName, bName, returnVariable)
            (quote
                $returnVariable = $aName * $bName;
            end).args
        end
        function compute(sumType::NormalizedSum, aName, bName, returnVariable)
            (quote
                $returnVariable = $aName + $bName / max(1.0, max($aName, $bName))
            end).args
        end

        function compute(sumType::Maximum, aName, bName, returnVariable)
            (quote
                $returnVariable = max(aName,bName)
            end).args
        end

        function compute(sumType::HamacherSum, aName, bName, returnVariable)
            (quote
                $returnVariable = ($aName + $bName - 2 * $aName * $bName) / (1 - $aName * $bName)
            end).args
        end

        function compute(sumType::EinsteinSum, aName, bName, returnVariable)
            (quote
                $returnVariable = ($aName + $bName) / (1.0 + $aName * $bName)
            end).args
        end

        function compute(sumType::DrasticSum, aName, bName, returnVariable)
            (quote
                if min($aName,$bName) == 0.0
                    $returnVariable = max($aName,$bName)
                 else
                    $returnVariable = 1.0
                end
            end).args
        end

        function compute(sumType::BoundedSum, aName, bName, returnVariable)
            (quote
                $returnVariable = min(1.0, $aName + $bName)
            end).args
        end

        function compute(sumType::AlgebraicSum, aName, bName, returnVariable)
            (quote
                $returnVariable = $aName + $bName - ($aName * $bName)
            end).args
        end
        ruleIdentifier = symbol("rule_$(ruleNumber)")
        proposition = rule.antecedent.head
        nameVariable = symbol("$(proposition.variable.name)_$(proposition.term.name)")
        blocksInferenceRule = Array(Any,0)
        blocksInferenceRule = [blocksInferenceRule, :($ruleIdentifier = $nameVariable)]
        for operator in rule.antecedent.tail
            proposition = operator.left
            nameVariable = symbol("$(proposition.variable.name)_$(proposition.term.name)")
            if operator.operator == Or()
                blocksInferenceRule = [blocksInferenceRule, compute(engineSkeleton.disjunction,ruleIdentifier,nameVariable,ruleIdentifier)]
            elseif operator.operator == And()
                blocksInferenceRule = [blocksInferenceRule, compute(engineSkeleton.conjunction,ruleIdentifier,nameVariable,ruleIdentifier)]
            end
        end
        return blocksInferenceRule
    end
    function convertBlocksIntoBlock(blocksInferenceRule, totalLines)
        linesOfCode = Array(Any,totalLines)
        counter = 0
        for block in blocksInferenceRule
            for line in block
                counter = counter + 1
                linesOfCode[counter] = line
            end
        end
        return linesOfCode
    end
    function generateInference(rules)
        counter = 0
        blockRules = Array(Array{Any,1},length(rules))
        totalLines = 0
        for rule in rules
            counter = counter + 1
            blockRules[counter] = createInference(rule, counter)
            totalLines = totalLines + length(blockRules[counter])
        end
        return convertBlocksIntoBlock(blockRules,totalLines)
    end
    function generateFinalValueOutputVariable(rules, outputVariables)

        blockInference = Array(Any,0)

        totalLines = 0
        for outputVariable in outputVariables
            for term in outputVariable.terms
                first = true
                counterRule = 0
                nameVariable = symbol("$(outputVariable.name)_$(term.name)")
                for rule in rules
                    counterRule = counterRule + 1
                    if hasVariableAndTerm(rule,outputVariable,term)
                        ruleNameVariable = symbol("rule_$(counterRule)")
                        if first
                            first = false
                            push!(blockInference,:($nameVariable = $ruleNameVariable))
                        else
                            push!(blockInference,:($nameVariable = max($nameVariable,$ruleNameVariable)))
                        end
                    end
                end
            end
        end
        return blockInference
    end
    function hasVariableAndTerm(rule,variable,term)
        proposition = rule.consequent.head
        if proposition.variable.name == variable.name && proposition.term.name == term.name
            return true
        end
        for operator in rule.consequent.tail
            proposition = operator.left
            if proposition.variable.name == variable.name && proposition.term.name == term.name
                return true
            end
        end
        return false
    end
    function generateDefuzzifier(variables)

        lines = Array(Any,0)

        for variable in variables
            sumAreaName = symbol("sumArea_$(variable.name)")
            sumAreaCenterName = symbol("sumAreaCenter_$(variable.name)")

            lastTermVertexC = 0.0
            tanLast = 0.0
            lastName = :nothing
            oldTerm = :nothing
            afterFirst = false

            push!(lines,:($sumAreaName = 0.0))
            push!(lines,:($sumAreaCenterName = 0.0))


            terms = sort(variable.terms, by=(term) -> term.vertexB)
            for term in terms
                nameVariable = symbol("$(variable.name)_$(term.name)")
                nameVariableArea = symbol("$(variable.name)_$(term.name)_area")
                range = abs(term.vertexA - term.vertexC)
                center = term.vertexB
                line = :($nameVariableArea = ($range - ($(term.tan) * $nameVariable)) * $nameVariable)
                push!(lines,line)
                line = :($sumAreaName = $sumAreaName + $nameVariableArea)
                push!(lines,line)
                line = :($sumAreaCenterName = $sumAreaCenterName + $nameVariableArea*$center)
                push!(lines,line)
                if afterFirst
                    currentTermVertexA = term.vertexA
                    tanCurrent = term.tan
                    solutionLinear = solveFast(LinearFunc(oldTerm.vertexC,0.0,oldTerm.vertexB,1.0),LinearFunc(term.vertexA,0.0,term.vertexB,1.0))

                    innerArea = (solutionLinear.y * (oldTerm.vertexC - term.vertexA)) / 2.0
                    innerCenter = (term.vertexA + oldTerm.vertexC + solutionLinear.x) / 3.0
                    linesInnerTrapezoid = generateInnerTrapezoid(oldTerm.vertexC,oldTerm.tan,lastName,term.vertexA,term.tan,nameVariable,sumAreaName,sumAreaCenterName)

                    tempLines = (quote
                        if $lastName > $(solutionLinear.y) && $nameVariable > $(solutionLinear.y)
                            $sumAreaName = $sumAreaName - $innerArea
                            $sumAreaCenterName = $sumAreaCenterName + $(-innerCenter)
                        else
                           $(linesInnerTrapezoid...)
                        end
                    end).args
                    lines = [lines, tempLines]
                    lastTermVertexC = term.vertexC
                    tanLast = term.tan
                    lastName = nameVariable
                    oldTerm = term
                else
                    afterFirst = true
                    oldTerm = term
                    lastName = nameVariable
                end
            end
            name = variable.name
            push!(lines,:($name = $sumAreaCenterName/$sumAreaName))
        end

        #push!(lines,:(@bp))
        if length(variables) > 1
            allVariablesReturn = Expr(:tuple,[x.name for x in variables]...)
            push!(lines,:(return $allVariablesReturn))
        elseif length(variables) == 1
            name = variables[1].name
            push!(lines,:(return $name))
        else
            throw(ParseError("No output variable in fuzzy block."))
        end
        return lines
    end
    function generateInnerTrapezoid(lastTermVertexC,tanLast, lastActivation, currentTermVertexA, tanCurrent,currentActivation,sumAreaName,sumAreaCenterName)
        nameStr = string(sumAreaName)
        (quote
        ############################
        ############****############
        ###########******###########
        ##########********##########
        #*******&&&&*******#########
        #############################
        #second case is when the  triangle that occupy both triangules is sliced forming a trapezoid so I have to calculate
        #his area and centroid.
        activationMin = min($lastActivation,$currentActivation)
        #activationMinSquared = activationMin * activationMin * 0.5

        baseTriangleLast = $tanLast * activationMin
        baseTriangleCurrent = $tanCurrent * activationMin

        centerOfMassLast = $lastTermVertexC - baseTriangleLast*0.666666666666666
        centerOfMassCurrent = $currentTermVertexA + baseTriangleCurrent*0.666666666666666

        areaTriangleLast = baseTriangleLast * activationMin *0.5
        areaTriangleCurrent = baseTriangleCurrent * activationMin *0.5

        innerSquareBase = $lastTermVertexC - $currentTermVertexA - baseTriangleLast - baseTriangleCurrent
        innerSquareArea = innerSquareBase * activationMin
        centerOfMassSquare = $currentTermVertexA+baseTriangleCurrent + innerSquareBase*0.5

        #sumAreaTrapezoid = innerSquareArea
        #sumAreaTrapezoid = sumAreaTrapezoid + areaTriangleLast
        #sumAreaTrapezoid = sumAreaTrapezoid + areaTriangleCurrent

        #sumAreaMultipliedByMidTermTrapezoid = innerSquareArea*centerOfMassSquare
        #sumAreaMultipliedByMidTermTrapezoid = sumAreaMultipliedByMidTermTrapezoid + areaTriangleLast*centerOfMassLast
        #sumAreaMultipliedByMidTermTrapezoid = sumAreaMultipliedByMidTermTrapezoid + areaTriangleCurrent*centerOfMassCurrent
        #centerOfMassTrapezoid = sumAreaMultipliedByMidTermTrapezoid / sumArea
        #print($nameStr)
        #print("=")
        #print(innerSquareArea*centerOfMassSquare - areaTriangleLast*centerOfMassLast - areaTriangleCurrent*centerOfMassCurrent)
        #print("\n")
        $sumAreaName = $sumAreaName - innerSquareArea - areaTriangleLast - areaTriangleCurrent
        $sumAreaCenterName = $sumAreaCenterName - innerSquareArea*centerOfMassSquare - areaTriangleLast*centerOfMassLast - areaTriangleCurrent*centerOfMassCurrent
        end).args
    end
    function fuzzyFunction(name, arguments, linesOfCode)
        quote
            function $name($(arguments...))
                $(linesOfCode...)
            end
        end
    end

    lines = Array(Any,0)
    #push!(lines,:(return 0.0))
    lines = [lines, generateFuzzifier(engineSkeleton.inputVariables)]
    #push!(lines,:(return 0.0))
    lines = [lines, generateInference(engineSkeleton.ruleBlocks[1].rules)]
    lines = [lines, generateFinalValueOutputVariable(engineSkeleton.ruleBlocks[1].rules,engineSkeleton.outputVariables)]
    lines = [lines, generateDefuzzifier(engineSkeleton.outputVariables)]

    lines = filter((x) -> typeof(x) != LineNumberNode && x.head != :line,lines)
    arguments = Array(Any,0)
    for inputVariable in engineSkeleton.inputVariables
        push!(arguments,inputVariable.name)
    end
    #=for line in lines
        print(line)
        print("\n")
    end=#
    #@bp
    functionFinal =  fuzzyFunction(engineSkeleton.name,arguments,lines)
    #@bp
    #print(functionFinal)

    return functionFinal
end
#=realmin(0.0)
string(:teste)
linesOfCode = [:(a = b + a),:(return b + c + a + 2)]
code = Expr(:block, linesOfCode...)

b = fuzzyFunction(:teste,[:a,:b,:c],linesOfCode)
c = eval(b)
c(1,2,3)

y = 2
d = :(x = x + 1)
e = quote
        x = x + 1
    end
d.head
e.head
a = quote
        function teste(a,b,c)
            x = x + $y
            x = x + 3
        end
    end
a
names(a)
a.head
a.typ
typeof(a.args)
length(a.args)
        a.args[1]
        a.args[2]
        a.args[2].head
        a.args[2].typ

length(a.args[2].args)
        a.args[2].args[1]
        a.args[2].args[2]
        a.args[2].args[2].head
        a.args[2].args[2].typ

length(a.args[2].args[1].args)
a.args[2].args[1].head
a.args[2].args[1].args[1]
a.args[2].args[1].args[2]
a.args[2].args[1].args[3]
a.args[2].args[1].args[4]

length(a.args[2].args[2].args)
        a.args[2].args[2].args[1]
        a.args[2].args[2].args[2]
        a.args[2].args[2].args[2].head
        a.args[2].args[2].args[2].typ

length(a.args[2].args[2].args[2].args)
        a.args[2].args[2].args[2]
        a.args[2].args[2].args[2].args[1]
        a.args[2].args[2].args[2].args[2]

length(a.args[2].args[2].args[4].args)
        a.args[2].args[2].args[4]
        a.args[2].args[2].args[2].args[2]

Expr(:call, :teste, [:a,:b,:c]...)
=#


