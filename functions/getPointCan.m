function pointCan = getPointCan(ptCloudROI)
    %GETPOINTCAN Summary of this function goes here
    %   Detailed explanation goes here

    pointCan = [mean(ptCloudROI.Location(:,1)); ...
        mean(ptCloudROI.Location(:,2)); ...
        mean(ptCloudROI.Location(:,3))];
end

