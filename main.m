% blockwoche - fh dortmund
% team vision
% subteam odometry


%% init

clear 
close all
clc

addpath('functions')
addpath('data')

% load map from navigation team
% load position and orientation per frame from navigation team
% load pose lidar - zed mini

load("stereoParams.mat");


%% get image data from zed using ros 

ip = 'http://10.0.109.207:11311';
rosinit(ip) % connectiong to ros master on jetson

%% 

% zed_sub_right = rossubscriber('/zedm/zed_node/right/image_rect_color/compressed');  % subcripe to topic
zed_sub_left = rossubscriber('/zedm/zed_node/left/image_rect_color/compressed');  % subcripe to topic
% zed_sub_pointCloud = rossubscriber('/zedm/zed_node/point_cloud/cloud_registered');  % 
zed_sub_info = rossubscriber('/zedm/zed_node/depth/camera_info');
% zed_sub_stereo = rossubscriber('/zedm/zed_node/stereo/image_rect_color');
zed_sub_depth = rossubscriber('/zedm/zed_node/depth/depth_registered');

%%

cam_info = receive(zed_sub_info);
focalLength = [info.K(1), info.K(3)];
principalPoint = [info.K(5), info.K(6)];
imageSize = [double(info.Height), double(info.Width)];
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

%%

% msg_sub_right = receive(zed_sub_right);  
msg_sub_left = receive(zed_sub_left);
msg_depth = receive(zed_sub_depth);

% im_sub_right = readImage(msg_sub_right);
im_sub_left = readImage(msg_sub_left);
im_depth = readImage(msg_depth);

%% 
ptCloud = pcfromdepth(im_depth, 1,intrinsics, 'ROI',rect);
ptCloud = getPtCloudWithoutNaN(ptCloud);

meanDistance = mean(ptCloud.Location(:,3));

