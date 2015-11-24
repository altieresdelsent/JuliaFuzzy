module TNorms
    #using Debug
    using ..Norms.TNorm
    type AlgebraicProduct <: TNorm
    end

    type BoundedDifference <: TNorm
    end

    type DrasticProduct <: TNorm
    end

    type EinsteinProduct <: TNorm
    end

    type HamacherProduct <: TNorm
    end

    type Minimum <: TNorm
    end
end
