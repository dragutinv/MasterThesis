function [ centerPixel ] = test( data )
%TEST Calculate entrophy of the block struct and to thresholding

centerPixel = data(ceil(size(data,2)/2), ceil(size(data,1)/2));

if (isempty(find(data < 10)) && isempty(find(data > 120)) == 0)
    if centerPixel > ((max(data(:)) + min(data(:)))/2)
        centerPixel = max(data(:));
    else
        centerPixel = min(data(:));
    end
end

end

