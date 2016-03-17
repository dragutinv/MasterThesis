function [ returnVal ] = isPlayShot( scene )
%ISPLAYSHOT Check if the scence contains play field 
% scene - image containing usual sport scene

%use sliding rectangle to check if the middle of the scene is homogenous


%J = m(scene);
%threshold = 4;

[h w ~] = size(scene);

%first patch
patch1 = scene(uint16(0.2*h):uint16(0.2*h+30), uint16(0.15*w):uint16(0.7*w), :);
patch2 = scene(uint16(0.3*h):uint16(0.3*h+30), uint16(0.15*w):uint16(0.7*w), :);
patch3 = scene(uint16(0.4*h):uint16(0.4*h+30), uint16(0.15*w):uint16(0.7*w), :);
patch4 = scene(uint16(0.5*h):uint16(0.5*h+30), uint16(0.15*w):uint16(0.7*w), :);
patch5 = scene(uint16(0.6*h):uint16(0.6*h+30), uint16(0.15*w):uint16(0.7*w), :);
patch6 = scene(uint16(0.7*h):uint16(0.7*h+30), uint16(0.15*w):uint16(0.7*w), :);

%imshow([patch1; patch2; patch4; patch5; patch6]);

end

