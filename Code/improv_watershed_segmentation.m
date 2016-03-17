function [ imgOut ] = improv_watershed_segmentation( courtImage )
%IMPROV_KMEANS_SEGMENTATION Summary of this function goes here
%   Detailed explanation goes here

cform = makecform('srgb2lab');
lab_he = applycform(courtImage,cform);

[nrows, ncols, ~] = size(courtImage);

I3 = imhmin(lab_he(:,:,1),60); 
pixel_labels = watershed(I3); 
imshow(label2rgb(pixel_labels,'jet','w'));
pause;

centerRows = uint16(nrows/2);
centerCols = uint16(ncols/2);

centerOfImage = pixel_labels((centerRows-200):(centerRows+100), (centerCols-300):(centerCols+300));

segments = unique(centerOfImage);

numSegments = numel(segments);
maxSegment = 0;
maxSegmentPixels = 0;
for i=1:numSegments
    numPixels = sum(sum(find(centerOfImage == segments(i))));
    if (numPixels > maxSegmentPixels)
        maxSegment = i;
        maxSegmentPixels = numPixels;
    end
end

mask = (pixel_labels == maxSegment);

mask = imfill(mask,'holes');

%keep only biggest component
CC = bwconncomp(mask);
numPixels = cellfun(@numel,CC.PixelIdxList);
[maxPixels,idx] = max(numPixels);

for i = 1:size(CC.PixelIdxList, 2)
    if i ~= idx
        if numel(CC.PixelIdxList{i}) < maxPixels*0.6
            mask(CC.PixelIdxList{i}) = 0;
        end
    end
end

mask = imdilate(mask,strel('disk',15));

mask = uint8(mask);

imgOut(:, :, 1) = courtImage(:,:, 1) .* mask;
imgOut(:, :, 2) = courtImage(:,:, 2) .* mask;
imgOut(:, :, 3) = courtImage(:,:, 3) .* mask;

end

