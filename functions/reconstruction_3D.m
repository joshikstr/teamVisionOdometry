function [point] = reconstruction_3D(im_stereo, intrinsics)

baseline = 63.0015*10^-3;
principalPoint = intrinsics.PrincipalPoint;
f = intrinsics.FocalLength;
%% detect can in left and right stereo image
imL = im_stereo(:,1:640,:);
imR = im_stereo(:,641:end,:);

canL = detect_Dosen(imL,true);
canR = detect_Dosen(imR,true);

[rectL, ~, ~] = decideCan(canL);
[rectR, ~, ~] = decideCan(canR);

%% mean value in left and right bbbox
x_l = rectL(1)+ 0.5*rectL(3);
y_l = rectL(2)+ 0.5*rectL(4);
 
leftPoint = [x_l,y_l];
 
x_r = rectR(1)+ 0.5*rectR(3);
y_r = rectR(2)+ 0.5*rectR(4);
 
rightPoint = [x_r,y_r];


%% 3D Points
u0 = principalPoint(1);
v0 = principalPoint(2);
 
d = rightPoint(1)-leftPoint(1);
d = abs(d);

X = (baseline*(leftPoint(1)-u0))./d;
% treshold abfragen für d 0.1
Y = (baseline*(leftPoint(2)-v0))./d;
Z = f(1)*baseline./d;

point = [X;Y;Z];

end
 