close all;
clear all;

addpath('line_detector');
addpath('programs');

folderModels = './CourtModels/';
show_Hough_lines = 0;
show_LSD_lines = 1;

imgCourtModels = dir(strcat(folderModels, '*.jpg'));
for i = 1 : length(imgCourtModels)
    courtModel = strcat(folderModels, imgCourtModels(i).name);
    courtImage = imread(courtModel);
    
    segmentedCourt = improv_kmeans_segmentation(courtImage, 0);
    
    %segmentedCourt = improv_lines_fourier(segmentedCourt);
    %figure (1);
    %imagesc(abs(segmentedCourt));
 
    
    %figure (1), imshow(mat2gray(imgBlackWhite)), hold on
    if (show_LSD_lines)
        % Line Detection Routine
        lines = line_detector(segmentedCourt);
        lineCount = size(lines,2);
        
        imshow(segmentedCourt); hold on;
        
        % Render the result
        for lineIndex=1:lineCount
            X1 =[lines(2,lineIndex); lines(4,lineIndex)];
            Y1 =[lines(1,lineIndex); lines(3,lineIndex)];
            plot(X1,Y1,'LineWidth',2,'Color',[1 0 0]);
        end
    end
    
    if (show_Hough_lines)
        cform = makecform('srgb2lab');
        lab_he = applycform(segmentedCourt,cform);
        segmentedCourt = lab_he(:,:,1);
        imgBlackWhite = segmentedCourt > 170;
        imgBlackWhite = bwareaopen(imgBlackWhite, 30);
        
        imshow(imgBlackWhite); hold on;
        
        [H,theta,rho] = hough(imgBlackWhite,'RhoResolution',2, 'ThetaResolution',0.5);
        P = houghpeaks(H,20,'threshold',ceil(0.2*max(H(:))));
        lines = houghlines(imgBlackWhite, theta, rho, P, 'FillGap', 40, 'MinLength',200);
        
        max_len = 0;
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
            
            % Plot beginnings and ends of lines
            plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
            plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        end
    end
    
    hold off;
    pause;
end
