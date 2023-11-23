function pointOut = coordinateTransformPoint(pointIn,T)
    %TRANSFORMPTCLOUD Summary of this function goes here
    %   Detailed explanation goes here
    
    pointOut = h2e(T * e2h(pointIn));

end

