function firstConfiguration(engine::EngineSkeleton)
	recreate = (old,intersectionPoint,innerArea,innerCenter) -> Triangle{typeof(0.0)}(old.name, old.vertexA,old.vertexC,intersectionPoint,innerArea,innerCenter)
	
	for variable::OutputVariable in engine.outputVariables
        variable.defuzzifier = engine.defuzzifier
        variable.fuzzyOutput.accumulation = engine.accumulation
        accumulator = variable.fuzzyOutput
        index = 0
        for i in 2:length(variable.terms)
			first = variable.terms[i-1]
			second = variable.terms[i]
			
			if first.vertexC > second.vertexA
				firstFunc = LinearFunc(first.vertexC,0.0,first.vertexB,1.0)
				secondFunc = LinearFunc(second.vertexA,0.0,second.vertexB,1.0)
				solution = solveFast(firstFunc,secondFunc)
				xEncounter = solution.x
				yEncounter = solution.y
				#@bp second.vertexA == 0.6
				innerCenter = (xEncounter + first.vertexC + second.vertexA) / 3.0
				innerArea = (yEncounter * (first.vertexC - second.vertexA)) / 2.0
				variable.terms[i] = recreate(variable.terms[i],[solution.x,solution.y],innerArea,innerCenter)
			end
			
		end

		variable.termsActivation = {term.name => 0.0 for term in variable.terms}
	end
end