close all;
clear all;

addpath('programs/Bilateral Filtering')

folderModels = './CourtModels/';
showLines = 1;

imgCourtModels = dir(strcat(folderModels, '*.jpg')); 
for i = 1 : length(imgCourtModels)
    courtModel = strcat(folderModels, imgCourtModels(i).name);
    courtImage = imread(courtModel);
    
    s = size(courtImage);
    
    w     = 5;       % bilateral filter half-width
    sigma = [100 0.15]; % bilateral filter standard deviations
    courtImage = bfilter2(im2double(courtImage),w,sigma);

    courtImage = uint8(courtImage * 255);
    
    figure(1);
    imshow(courtImage);
    
    pause;
end
