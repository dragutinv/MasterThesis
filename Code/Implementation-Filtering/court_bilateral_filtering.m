function [ outImage ] = court_bilateral_filtering( courtImage )
%COURT_BILATERAL_FILTERING Apply bilateral filter on court image

addpath('./programs/Bilateral Filtering');

w = 10;       % bilateral filter half-width
sigma = [100 1.15]; % bilateral filter standard deviations
courtImage = bfilter2(im2double(courtImage),w,sigma);

outImage = uint8(courtImage * 255);

end

