close all;
clear all;

addpath('vlfeat-0.9.20');

folderModels = './InputData/CourtModels/';
show_Hough_lines = 0;
show_LSD_lines = 0;

imgCourtModels = dir(strcat(folderModels, '*.jpg'));
for i = 1 : length(imgCourtModels)
    courtModel = strcat(folderModels, imgCourtModels(i).name);
    courtImage = imread(courtModel);
    
    
    %segmentedCourt = improv_kmeans_segmentation(courtImage, 0);
    figure(1); imshow(courtImage); hold on;
    
    I = single(rgb2gray(courtImage));
    [f,d] = vl_sift(I);
    
    perm = randperm(size(f,2)) ;
    sel = perm(1:10) ;
    h1 = vl_plotframe(f(:,sel)) ;
    h2 = vl_plotframe(f(:,sel)) ;
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','y','linewidth',2) ;
 
    hold off;
    
    pause;
end
