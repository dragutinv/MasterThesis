function [ centerPixel ] = templateMatching( data )
%TEMPLATEMATCHING Summary of this function goes here

centerPixel = data(ceil(size(data,2)/2), ceil(size(data,1)/2));

numPixels = length(find(data > 100));
windowSize = size(data,2)*size(data,1);

if (numPixels > windowSize*0.1 && numPixels < windowSize*0.4 )
    figure(5);
    imshow(data);
    pause;
end

end

