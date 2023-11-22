function ptCloudOut = getPtCloudWithoutNaN(ptCloudIn)
%GETVALIDPTCLOUD Summary of this function goes here
%   Detailed explanation goes here
    x = ptCloudIn.Location(:,:,1);
    y = ptCloudIn.Location(:,:,2);
    z = ptCloudIn.Location(:,:,3);
     
    nanIndices = isnan(z);
    
    x = x(~nanIndices);
    y = y(~nanIndices);
    z = z(~nanIndices);
    
    ptCloudOut = pointCloud([x,y,z]);
end

