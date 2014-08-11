#this file is imported in the Norm module
using .SNorms.NormalizedSum
using .SNorms.Maximum
using .SNorms.HamacherSum
using .SNorms.EinsteinSum
using .SNorms.DrasticSum
using .SNorms.BoundedSum
using .SNorms.AlgebraicSum

function compute(sumType::NormalizedSum, a, b)
    return a + b / max(1.0, max(a, b));
end

function compute(sumType::Maximum, a, b)
    return max(a,b);
end

function compute(sumType::HamacherSum, a, b)
    return (a + b - 2 * a * b) / (1 - a * b);
end

function compute(sumType::EinsteinSum, a, b)
    return (a + b) / (1.0 + a * b);
end

function compute(sumType::DrasticSum, a, b)
    if min(a,b) == 0.0
        return max(a,b);
     else
        return 1.0
     end
end

function compute(sumType::BoundedSum, a, b)
    return min(1.0, a +b);
end

function compute(sumType::AlgebraicSum, a, b)
     #print("\ta:")
     #print(a)
     #print("b:")
     #print(b)
     #print("a + b - (a * b)")
     #print(a + b - (a * b))
    return a + b - (a * b);
end
