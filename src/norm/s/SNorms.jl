module SNorms
    #using Debug
    using ..Norms: SNorm

    mutable struct AlgebraicSum <: SNorm
    end

    mutable struct BoundedSum <: SNorm
    end

    mutable struct DrasticSum <: SNorm
    end

    mutable struct EinsteinSum <: SNorm
    end

    mutable struct HamacherSum <: SNorm
    end

    mutable struct Maximum <: SNorm
    end

    mutable struct NormalizedSum <: SNorm
    end
end
