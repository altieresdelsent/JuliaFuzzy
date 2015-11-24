#this file is imported in the Norms module
using .TNorms.Minimum
using .TNorms.HamacherProduct
using .TNorms.EinsteinProduct
using .TNorms.DrasticProduct
using .TNorms.BoundedDifference
using .TNorms.AlgebraicProduct

function compute(tType::Minimum, a, b)
    return min(a, b);
end

function compute(tType::HamacherProduct, a, b)
    return (a * b) / (a + b - a * b);
end

function compute(tType::EinsteinProduct, a, b)
    return (a * b) / (2 - (a + b - a * b));
end

function compute(tType::DrasticProduct, a,b)
    if max(a, b) == 1.0
        return min(a, b);
    end
    return 0.0;
end

function compute(tType::BoundedDifference,a ,b)
    return max(0.0, a + b - 1);
end

function compute(tType::AlgebraicProduct, a, b)
    #print("\ta:")
    #print(a)
    #print("b:")
    #print(b)
    #print("a * b")
    #print(a * b)
    return a * b;
end
