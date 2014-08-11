const __exp1 = exp(-1);
const __exp2 = exp(-2);
const __exp3 = exp(-3);
const __exp4 = exp(-4);
const __exp5 = exp(-5);
const __exp6 = exp(-6);
const __exp7 = exp(-7);
const __exp8 = exp(-8);
const __1divideby24 = 1/24;
function fastExp(x)
    if x <= -8.0
       return __exp8
    end

    integerPart = trunc(x);
    rest = x - integerPart;
    restReturn = 1.0
    if rest != 0.0
        restReturn = (24.0 + rest * (24.0 + rest * (12.0 + rest * (4.0 + rest)))) * __1divideby24
    end

    if  integerPart > -4.0
        if integerPart >= -2.0
            if integerPart == -3.0
                return __exp3 * restReturn;
            else
                return __exp2 * restReturn;
            end
        else
            if integerPart == -1.0
                return __exp1 * restReturn;
            else
                return restReturn;
            end
        end
    else
        if integerPart <= -6.0
            if(integerPart == -7.0)
                return __exp7 * restReturn;
            else
                return __exp6 * restReturn;
            end
        else
            if integerPart == -5.0
                return __exp5 * restReturn;
            else
                return __exp4 * restReturn;
            end
         end
     end
end
