module TNorms
    #using Debug
    using ..Norms: TNorm
    mutable struct AlgebraicProduct <: TNorm
    end

    mutable struct BoundedDifference <: TNorm
    end

    mutable struct DrasticProduct <: TNorm
    end

    mutable struct EinsteinProduct <: TNorm
    end

    mutable struct HamacherProduct <: TNorm
    end

    mutable struct Minimum <: TNorm
    end
end
