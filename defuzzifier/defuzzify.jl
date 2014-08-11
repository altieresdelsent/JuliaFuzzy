using ..Terms.Term
using ..Terms.membership
function defuzzify(tType::Centroid,term::Term, minimum, maximum)
    if (maximum - minimum) > tType.resolution
        warn("[accuracy warning] the resolution <$tType.resolution> is smaller than the range <$minimum , $maximum>. In order to improve the accuracy, the resolution should be at least equal to the range.");
    end
    dx = (maximum - minimum) / tType.resolution;
    x = 0.0; y = 0.0;
    area = 0.0; xcentroid = 0.0; ycentroid = 0.0;
    current = (0.5) * dx;
    for  i in 0.0:tType.resolution
        #print("\n")
        #print("\t\t\tx:")
        x = minimum + current;
        #print(x)

        current = current + dx
        #print("\ty:(")
        y = membership(term,x);
        #print(")")
        #print(y)

        #print("\txcentroid:")
        xcentroid = xcentroid + y * x;
        #print(xcentroid)
        #ycentroid = ycentroid + y * y;
        #print("\tarea:")
        area += y;
        #print(area)
    end
    #print("\n")
    #print("\t\t\txcentroidFINAL:")
    xcentroid = xcentroid / area;
    #ycentroid /= 2 * area;
    #area *= dx; #total area... unused, but for future reference.
    return xcentroid;
end
