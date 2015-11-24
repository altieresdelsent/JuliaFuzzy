using ..Terms.Term
using ..Terms.DoesNotMatterTerm
using ..Terms.membership
#using Debug
const excludeTerm = DoesNotMatterTerm()
function defuzzify(tType::Centroid, output)
    term = output.fuzzyOutput
    minimum = output.fuzzyOutput.minimum
    maximum = output.fuzzyOutput.maximum
    if (maximum - minimum) > tType.resolution
        tType.resolution = abs(maximum - minimum)
        #warn("[accuracy warning] the resolution <$tType.resolution> is smaller than the range <$minimum , $maximum>. In order to improve the accuracy, the resolution should be at least equal to the range.");
    end
    dx = (maximum - minimum) / tType.resolution
    #print("maximum=$maximum,minimum=$minimum)")
    x = 0.0; y = 0.0
    area = 0.0; xcentroid = 0.0; ycentroid = 0.0
    current = (0.5) * dx
    #cacheToPlot = zeros(2,101)
    for  i in 0.0:tType.resolution
        #print("\n")
        #print("\t\t\tx:")
        x = minimum + (i + 0.5) * dx
        #cacheToPlot[1,i+1] = x
        #print(x)

        #current = current + dx
        #print("\ty:(")
        y = membership(term,x)
        #cacheToPlot[2,i+1] = y
        #print(")")
        #print(y)

        #print("\txcentroid:")
        xcentroid = xcentroid + y * x
        #print(xcentroid)
        #ycentroid = ycentroid + y * y;
        #print("\tarea:")
        area += y
        #print(area)
    end
    #print("\n")
    #print("\t\t\txcentroidFINAL:")
    #writecsv("C:/Users/altieres/Box Sync/Mestrado/Dissertacao/materialJuliaLang/tt.csv",cacheToPlot)
    xcentroid = xcentroid / area
    #ycentroid /= 2 * area;
    #area *= dx; #total area... unused, but for future reference.
    return xcentroid
end
 function getInnerTrapezoid(lastTerm, lastActivation, currentTerm,currentActivation, sumArea, sumAreaMultipliedByMidTerm)
    ############################
    ############****############
    ###########******###########
    ##########********##########
    #*******&&&&*******#########
    #############################
    #second case is when the  triangle that occupy both triangules is sliced forming a trapezoid so I have to calculate
    #his area and centroid.
        activationMin = min(lastActivation,currentActivation)
        #activationMinSquared = activationMin * activationMin * 0.5

        baseTriangleLast = lastTerm.tan * activationMin
        baseTriangleCurrent = currentTerm.tan * activationMin
        
        centerOfMassLast = lastTerm.vertexC - baseTriangleLast*0.666666666666666
        centerOfMassCurrent = currentTerm.vertexA + baseTriangleCurrent*0.666666666666666

        areaTriangleLast = baseTriangleLast * activationMin *0.5
        areaTriangleCurrent = baseTriangleCurrent * activationMin *0.5

        innerSquareBase = lastTerm.vertexC - currentTerm.vertexA - baseTriangleLast - baseTriangleCurrent
        innerSquareArea = innerSquareBase * activationMin
        centerOfMassSquare = currentTerm.vertexA+baseTriangleCurrent + innerSquareBase*0.5

        #sumAreaTrapezoid = innerSquareArea
        #sumAreaTrapezoid = sumAreaTrapezoid + areaTriangleLast
        #sumAreaTrapezoid = sumAreaTrapezoid + areaTriangleCurrent

        #sumAreaMultipliedByMidTermTrapezoid = innerSquareArea*centerOfMassSquare
        #sumAreaMultipliedByMidTermTrapezoid = sumAreaMultipliedByMidTermTrapezoid + areaTriangleLast*centerOfMassLast
        #sumAreaMultipliedByMidTermTrapezoid = sumAreaMultipliedByMidTermTrapezoid + areaTriangleCurrent*centerOfMassCurrent
        #centerOfMassTrapezoid = sumAreaMultipliedByMidTermTrapezoid / sumArea

        sumArea = sumArea - innerSquareArea - areaTriangleLast - areaTriangleCurrent
        sumAreaMultipliedByMidTerm = sumAreaMultipliedByMidTerm - innerSquareArea*centerOfMassSquare - areaTriangleLast*centerOfMassLast - areaTriangleCurrent*centerOfMassCurrent
        return (sumArea,sumAreaMultipliedByMidTerm)
end
 function processTerm(lastTerm, lastActivation, currentTerm,currentActivation)

    baseTriangle = currentTerm.tan * currentActivation
    baseInnerSquare = currentTerm.range - baseTriangle
    area = baseInnerSquare * currentActivation
    sumArea =  area
    sumAreaMultipliedByMidTerm = area * currentTerm.vertexB
    #I have to subtract the area that is from both trapezoids. (&&&) part
    #The only part where the lastTerm and the currentTerm are the same
    if lastTerm != currentTerm && lastActivation > 1e-5
        ############################
        ####****####****############
        ###******##******###########
        ##*******&&*******##########
        #*******&&&&*******#########
        #############################
        #First case is when the entire triangle that occupy both triangules in the defuzzification
        # are fully used, so I just can use the same.
        y = currentTerm.intersectionPoint[2]
        if lastActivation > y && currentActivation > y
            sumArea = sumArea - currentTerm.innerArea
            sumAreaMultipliedByMidTerm = sumAreaMultipliedByMidTerm - currentTerm.innerArea * currentTerm.innerCenter
        else
            return getInnerTrapezoid(lastTerm, lastActivation, currentTerm,currentActivation,sumArea,sumAreaMultipliedByMidTerm)      
        end 
    end
    return (sumArea,sumAreaMultipliedByMidTerm)
end
 function defuzzify(tType::FastCentroid, output)

    termsToProcess = output.fuzzyOutput.terms
    #@bp
    
    currentTerm = termsToProcess[1].term
    currentName = currentTerm.name
    currentActivation = termsToProcess[1].degree
    lastActivation = currentActivation
    counterActivateds = 0
    lastTerm = currentTerm
    lastActivatedTerm = currentTerm
    sumArea = 0.0
    sumAreaMultipliedByMidTerm = 0.0
    for activated in termsToProcess
        if activated.term != excludeTerm
            hasTermActivated = true

            #output.termsActivation[currentName] = max(output.termsActivation[currentName], activated.degree)
            if currentName != activated.term.name
                if currentActivation > 1e-5
                    counterActivateds = counterActivateds + 1
                    lastActivatedTerm = currentTerm
                    (sumAreaT,sumAreaMultipliedByMidTermT) = processTerm(lastTerm,lastActivation,currentTerm,currentActivation)
                    sumArea = sumArea + sumAreaT
                    sumAreaMultipliedByMidTerm =  sumAreaMultipliedByMidTerm + sumAreaMultipliedByMidTermT
                end
                lastTerm = currentTerm
                lastActivation = currentActivation

                currentTerm = activated.term
                currentName = currentTerm.name
                currentActivation = activated.degree
            else
                currentActivation = max(currentActivation, activated.degree)
            end
        end
    end

    if currentActivation > 1e-5
        counterActivateds = counterActivateds + 1
        lastActivatedTerm = currentTerm
        (sumAreaT,sumAreaMultipliedByMidTermT) = processTerm(lastTerm,lastActivation,currentTerm,currentActivation)
        sumArea = sumArea + sumAreaT
        sumAreaMultipliedByMidTerm =  sumAreaMultipliedByMidTerm + sumAreaMultipliedByMidTermT
    end

    if counterActivateds == 0
        #warn("No term in variable has $output.name has been activated.")
        return 0.0
    elseif counterActivateds == 1
        return lastActivatedTerm.vertexB
    end
    
    #for name in output.termsName
    #    name = variableTerm.name
    #    baseTriangle = output.tan1 * output.termsActivation[name]
    #    baseInnerSquare = variableTerm.range - baseTriangle
    #    area = baseInnerSquare * output.termsActivation[name]
    #    sumArea = sumArea + area
    #    sumAreaMultipliedByMidTerm = sumAreaMultipliedByMidTerm + area * variableTerm.vertexB
    #end
    return sumAreaMultipliedByMidTerm/sumArea
end
