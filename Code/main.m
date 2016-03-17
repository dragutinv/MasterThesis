close all;
clear all;

videos = {'RollandGarros', 'Wimbledon', 'LondonFinals'};
testVideo = 3;
v = VideoReader(strcat('Matches/', char(videos(testVideo)), '.mp4'));

i = 1;
while hasFrame(v)
    videoFrame = readFrame(v);
    
    if i > 34
        %pause;
        
    end
    
    i = i+1;
    
end