function [ imgOut ] = court_kmeans_segmentation( courtImage, debug )
%IMPROV_KMEANS_SEGMENTATION Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    debug = 0;
end

%bluredCourt = court_bilateral_filtering(courtImage);
bluredCourt = imgaussfilt(courtImage, 10);
cform = makecform('srgb2lab');
lab_he = applycform(bluredCourt,cform);

ab = double(lab_he(:,:,2:3));

[nrows ncols ~] = size(ab);
ab = reshape(ab,nrows*ncols,2);

nColors = 3;

% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',5);
pixel_labels = reshape(cluster_idx,nrows,ncols);


if debug == 1
    imshow(label2rgb(pixel_labels,'jet','w'));
    pause;
end

centerRows = uint16(nrows/2);
centerCols = uint16(ncols/2);

centerOfImage = pixel_labels((centerRows-100):(centerRows+100), (centerCols-50):(centerCols+50));


%find mask that segments center of the court
segment1count = sum(sum(find(centerOfImage == 1)));
segment2count = sum(sum(find(centerOfImage == 2)));
segment3count = sum(sum(find(centerOfImage == 3)));
%segment4count = sum(sum(find(centerOfImage == 4)));

[~, maxSegment] = max([segment1count segment2count segment3count]);
mask = (pixel_labels == maxSegment);

%mask = imdilate(mask,strel('square', 10));
%mask = imfill(mask,'holes');

if debug == 1
    figure(2);
    subplot(1, 2, 1);
    imshow(label2rgb(pixel_labels,'jet','w'));
    subplot(1, 2, 2);
    imshow(label2rgb(mask,'jet','w'));
    pause;
end

%keep only biggest component
CC = bwconncomp(mask);
numPixels = cellfun(@numel,CC.PixelIdxList);
[maxPixels,idx] = max(numPixels);

for i = 1:size(CC.PixelIdxList, 2)
    if i ~= idx
        if numel(CC.PixelIdxList{i}) < maxPixels*0.7
            mask(CC.PixelIdxList{i}) = 0;
        end
    end
end

mask = imdilate(mask,strel('square',30));

mask = uint8(mask);

imgOut(:, :, 1) = courtImage(:,:, 1) .* mask;
imgOut(:, :, 2) = courtImage(:,:, 2) .* mask;
imgOut(:, :, 3) = courtImage(:,:, 3) .* mask;

end

