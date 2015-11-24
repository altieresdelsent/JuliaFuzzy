module SNorms
    #using Debug
    using ..Norms.SNorm

    type AlgebraicSum <: SNorm
    end

    type BoundedSum <: SNorm
    end

    type DrasticSum <: SNorm
    end

    type EinsteinSum <: SNorm
    end

    type HamacherSum <: SNorm
    end

    type Maximum <: SNorm
    end

    type NormalizedSum <: SNorm
    end
end
