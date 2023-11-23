function msgPoint = point2PointMsg(msgPoint, point)
    %POINTINTOPOINTMSG Summary of this function goes here
    %   Detailed explanation goes here

    msgPoint.X = point(1); 
    msgPoint.Y = point(2);
    msgPoint.Z = point(3);
end

