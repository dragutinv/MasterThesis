close all;
clear all;

folderModels = './CourtModels/';
showLines = 0;

imgCourtModels = dir(strcat(folderModels, '*.jpg'));  % the folder with different court models
for i = 1 : length(imgCourtModels)
    courtModel = strcat(folderModels, imgCourtModels(i).name);
    courtImage = imread(courtModel);
    
    x = rgb2hsv(courtImage);
    imgBlackWhite = (x(:, :, 2) < 0.25 & x(:,:,3) > 0.7);
    %imgBlackWhite = imfill(imgBlackWhite,'holes');
    
    figure (1), imshow(imgBlackWhite), hold on
    
    if (showLines)
        [H,theta,rho] = hough(imgBlackWhite,'RhoResolution',0.5,'ThetaResolution',0.5);
        P = houghpeaks(H,20,'threshold',ceil(0.2*max(H(:))));
        lines = houghlines(imgBlackWhite, theta, rho, P, 'FillGap', 30, 'MinLength',20);
        
        max_len = 0;
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            
            % Plot beginnings and ends of lines
            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        end
    end
    pause;
end
