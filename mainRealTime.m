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

load('LiDARPoseCam.mat')    % load pose lidar - zed mini

%% starting ros

ip = 'http://10.0.109.133:11311';
rosinit(ip, 'NodeName','team_vision') % connectiong to ros master on jetson

%% subcripe topics

zed_sub_right = rossubscriber('/zedm/zed_node/right/image_rect_color/compressed');  
zed_sub_left = rossubscriber('/zedm/zed_node/left/image_rect_color/compressed');  
zed_sub_info = rossubscriber('/zedm/zed_node/depth/camera_info');
zed_sub_stereo = rossubscriber('/zedm/zed_node/stereo/image_rect_color');
zed_sub_depth = rossubscriber('/zedm/zed_node/depth/depth_registered');

% tf_sub = rossubscriber('/tf');
tf_sub = rossubscriber('/odom');

%% create topic publisher

point_pub = rospublisher('/point_can','geometry_msgs/Point');
point_name_pub = rospublisher('/point_can_name', 'std_msgs/String');
point_bool_pub = rospublisher('/point_can_bool', 'std_msgs/Bool');
msgPointCan = rosmessage(point_pub);
msgPointCanBool = rosmessage(point_bool_pub);
msgPointCanName = rosmessage(point_name_pub);

%% get initrinsics

cam_info = receive(zed_sub_info);
focalLength = [cam_info.K(1), cam_info.K(5)];
principalPoint = [cam_info.K(3), cam_info.K(6)];
imageSize = [double(cam_info.Height), double(cam_info.Width)];
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

%% main loop

while true
    
    % get data from ROS
  
    msg_left = receive(zed_sub_left);
    msg_depth = receive(zed_sub_depth);
    msg_tf = receive(tf_sub);
    
    im_left = readImage(msg_left);
    im_depth = readImage(msg_depth);
    
    % get point of can
    
    detectedCans = detect_Dosen(im_left,true);
    
    [bbox, name, isCan] = decideCan(detectedCans);
    
    if isCan 
        
        msgPointCanBool.Data = isCan;
        
        ptCloud = pcfromdepth(im_depth, 1, intrinsics,'ROI',bbox);
        ptCloud = getPtCloudWithoutNaN(ptCloud);
    
        ROI = [-10 10 -10 10 0.15 1.7];
        indices = findPointsInROI(ptCloud,ROI);
        ptCloud = select(ptCloud, indices);
        
        pointCan = getPointCan(ptCloud);
        if any(isnan(pointCan))
            disp('now')
            msg_stereo = receive(zed_sub_stereo);
            im_stereo = readImage(msg_stereo);
            pointCan = reconstruction_3D(im_stereo,intrinsics);
        end
        pointCanLiDAR = coordinateTransformPoint(pointCan,LiDARPoseCam);
        worldPoseLiDAR = odomMsg2Pose(msg_tf);
        pointCanWorld = coordinateTransformPoint(pointCanLiDAR,worldPoseLiDAR);
        msgPointCan = point2PointMsg(msgPointCan,pointCanWorld);
        
        msgPointCanName.Data = name;
        send(point_name_pub,msgPointCanName);
        send(point_pub,msgPointCan);
        send(point_bool_pub,msgPointCanBool);
        disp(name)
        disp(pointCanWorld)
    else
        msgPointCanBool.Data = isCan;
        send(point_bool_pub,msgPointCanBool);
    end
end