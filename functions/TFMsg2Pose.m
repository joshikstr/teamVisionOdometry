function pose = TFMsg2Pose(msg_tf)
    %TRANSFORMTFMSGINTOPOSE Summary of this function goes here
    %   Detailed explanation goes here
     trans = [msg_tf.Transforms.Transform.Translation.X; ...
         msg_tf.Transforms.Transform.Translation.Y;...
         msg_tf.Transforms.Transform.Translation.Z];

     quat = [msg_tf.Transforms.Transform.Rotation.W, ...
         msg_tf.Transforms.Transform.Rotation.X, ...
         msg_tf.Transforms.Transform.Rotation.Y, ...
         msg_tf.Transforms.Transform.Rotation.Z];

     pose = quat2tform(quat);
     pose(1:3,4) = trans;
    
end

