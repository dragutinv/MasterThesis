close all;
clear all;

addpath('programs');
addpath('LineDetectionAlgorithms');
addpath('LineDetectionAlgorithms/line_detector');
addpath('Implementation-Filtering');
addpath('Implementation-Segmentation');
addpath('Implementation-ColorAdjustment');

folderModels = './InputData/CourtModels/';
folderModelsBw = './InputData/CourtModels-bw/';
folderTemplates = './InputData/Templates/';

%algorithm steps
do_preprocessing = 1;
show_Hough_lines = 0;
show_LSD_lines = 0;
improv_lines_Foourier = 0;
show_template_matching = 0;

%debug options
debug_preprocessing = 1;
debug_segmentation = 0;
debugLineOutliers = struct;
debugLineOutliers.debugLineElimination = 0;
debugLineOutliers.debugParalelLines = 0;
debugLineOutliers.debugMergeLines = 0;

imgCourtModels = dir(strcat(folderModels, '*.jpg'));
for i = 1 : length(imgCourtModels)
    courtModel = strcat(folderModels, imgCourtModels(i).name);
    courtImage = imread(courtModel);
    
    if do_preprocessing == 1
        segmentedCourt = court_kmeans_segmentation(imsharpen(courtImage), debug_segmentation);
        
        if debug_segmentation == 1
            figure(3); imshow(segmentedCourt); %hold on;
            pause;
        end
        
        cform = makecform('srgb2lab');
        lab_he = applycform(segmentedCourt,cform);
        %hsv = rgb2hsv(segmentedCourt);
        x = lab_he(:,:,1);
        %fun = @(block_struct) imadjust(block_struct.data, [0.45 1], [0.00001 1]);
        %normalisedCourt = blockproc(x,[30 30], fun);
        %normalisedCourt = nlfilter(x, [3 3], @test);
        
        %threshLevel = (max(max(normalisedCourt(normalisedCourt > 10)))/2) + ...
        %    (min(min(normalisedCourt(normalisedCourt > 10)))/2);
        %level = graythresh(normalisedCourt(normalisedCourt > threshLevel));
        %bwCourt = normalisedCourt >= level*255;
        %bwCourt = uint8(bwCourt*255);
        %bwCourt = imclearborder(bwCourt);
        %bwCourt = bwareaopen(bwCourt, 100);
        
        l1 = log(double(segmentedCourt(:,:,1)) ./ double(segmentedCourt(:,:,2))); 
        l2 = log(double(segmentedCourt(:,:,3)) ./ double(segmentedCourt(:,:,2))); 
        bwCourt = l1 > -0.2 & l1 < 0.2 & l2 > -0.2 & l2 < 0.2;
        bwCourt = uint8(bwCourt*255);
        
        if debug_preprocessing == 1
            figure(1);
            %imshow([normalisedCourt bwCourt*255]);
            imshow(bwCourt);
            pause;
        end 
        
        ratio = 256/size(bwCourt, 2);
        imwrite(imresize(bwCourt, ratio),strcat(folderModelsBw, imgCourtModels(i).name));
    else
        bwCourt = imread(strcat(folderModelsBw, imgCourtModels(i).name));
        if debug_preprocessing == 1
            figure(3);
            imshow(bwCourt);
            pause;
        end 
        
        %nlfilter(bwCourt, [50 50], @templateMatching);
    end
    
    
    %use template matching to find corners
    if show_template_matching == 1
        imgTemplates = dir(strcat(folderTemplates, '*.jpg'));
        for q = 1 : length(imgTemplates)
            imgTemplateName = strcat(folderTemplates, imgTemplates(q).name);
            imgTemplate = imread(imgTemplateName);
            
            [position] = courtDetection_template_matching(bwCourt, rgb2gray(imgTemplate));
            figure(1);
            imshow(bwCourt);
            imrect(gca, position);
            pause;
        end
    end
    
    %improv borders using high pass filter
    if improv_lines_Foourier == 1
        imafft = SimpleFiltering(rgb2gray(segmentedCourt), 1, 0.2);
        ima_out = fftshift(ifft2(fftshift(imafft)));
        segmentedCourt1 = mat2gray(abs(ima_out));
        
        segmentedCourt1 = segmentedCourt1 - min(segmentedCourt1(:)) ;
        segmentedCourt1 = segmentedCourt1 / max(segmentedCourt1(:)) ;
        
        x = im2double(x);
        x = x + segmentedCourt1;
        segmentedCourt1 = x;
        segmentedCourt1 = segmentedCourt1 - min(segmentedCourt1(:)) ;
        segmentedCourt1 = segmentedCourt1 / max(segmentedCourt1(:)) ;
        
        normalisedCourt = segmentedCourt1;
        normalisedCourt = uint8(normalisedCourt*255);
    end
    
    if (show_LSD_lines)
        % Line Detection Routine
        lines = line_detector(bwCourt);
        whiteLines = [];
        lineCount = size(lines,2);
        
        %remove lines that don't have white pixels in neigbourhood
        for k=1:lineCount
            %check if line contains white pixels
            
            x =[lines(2,k) lines(4,k)];
            y =[lines(1,k) lines(3,k)];
            
            if (x(1) > size(bwCourt, 2) || x(1) > size(bwCourt, 2) || ...
                    y(1) > size(bwCourt, 1) || y(2) > size(bwCourt, 1) || ...
                    x(1) < 1 || x(2) < 1 || y(1) < 1 || y(2) < 1)
                continue;
            end
            
            [m, n] = size(bwCourt);
            
            
            %find 4 neigbour line with highest mean pixel value
            [pX, pY] = bresenham(x(1), y(1), x(2), y(2));
            [l1, l2, l3, l4, l5, l6, l7, l8] = linePixels(m, n, x, y, 1);
            [pX1, pY1] = bresenham(l1, l2, l3, l4);
            [pX2, pY2] = bresenham(l5, l6, l7, l8);
            
            [l9, l10, l11, l12, l13, l14, l15, l16] = linePixels(m, n, x, y, 2);
            [pX3, pY3] = bresenham(l9, l10, l11, l12);
            [pX4, pY4] = bresenham(l13, l14, l15, l16);
            
            [l17, l18, l19, l20, l21, l22, l23, l24] = linePixels(m, n, x, y, 5);
            [pX5, pY5] = bresenham(l17, l18, l19, l20);
            [pX6, pY6] = bresenham(l21, l22, l23, l24);
            
            meanPixelValue = mean(diag(bwCourt(pY, pX)));
            meanPixelValue1 = mean(diag(bwCourt(pY1, pX1)));
            meanPixelValue2 = mean(diag(bwCourt(pY2, pX2)));
            meanPixelValue3 = mean(diag(bwCourt(pY3, pX3)));
            meanPixelValue4 = mean(diag(bwCourt(pY4, pX4)));
            
            [meanPixelValueLine, pos] = max([meanPixelValue meanPixelValue1 meanPixelValue2 meanPixelValue3 meanPixelValue4]);
            if pos == 1
                candidateLine = [y(1) x(1) y(2) x(2)];
            elseif pos == 2
                candidateLine = [l2, l1, l4, l3];
            elseif pos == 3
                candidateLine = [l6, l5, l8, l7];
            elseif pos == 4
                candidateLine = [l10, l9, l12, l11];
            elseif pos == 5
                candidateLine = [l14, l13, l16, l15];
            end
            
            if debugLineOutliers.debugLineElimination == 1
                figure(3);
                imshow(bwCourt); hold on;
                plot([candidateLine(2) candidateLine(4)], [candidateLine(1) candidateLine(3)],'Color','red', 'LineWidth', 2);
                plot(x, y,'Color','blue');
                disp(strcat('Mean pixel:', num2str(meanPixelValueLine)));
                pause;
            end
            
            if (meanPixelValueLine >= 100)
                whiteLines = [whiteLines; candidateLine];
                if debugLineOutliers.debugLineElimination == 1
                    plot([candidateLine(2) candidateLine(4)], [candidateLine(1) candidateLine(3)], 'LineWidth',2,'Color','green');
                    pause;
                end
            end
        end
        
        lineCount = size(whiteLines,1);
        
        figure(3);
        imshow(courtImage); hold on;
        %show filtered white lines
        for k=1:lineCount
            x =[whiteLines(k, 2) whiteLines(k, 4)];
            y =[whiteLines(k, 1) whiteLines(k, 3)];
            plot(x, y, 'LineWidth',2,'Color','red');
        end
        
        hold off;
        pause;
        
        lineGroups = courtDetection_eliminate_line_outliers(courtImage, whiteLines, debugLineOutliers);
        
        figure(3);
        imshow(courtImage); hold on;
        
        for m=1:size(lineGroups, 1)
            plot(lineGroups(m, 2:3), lineGroups(m, 4:5), 'LineWidth',2,'Color','cyan');
        end
        
        hold off;
        pause;
    end
    
    if (show_Hough_lines)
        [H,theta,rho] = hough(bwCourt,'RhoResolution',1, 'ThetaResolution',0.5);
        P = houghpeaks(H, 15, 'threshold',ceil(0.34*max(H(:))));
        lines = houghlines(bwCourt, theta, rho, P, 'FillGap', 30, 'MinLength',20);
        
        disp(strcat('Number of lines: ', num2str(length(lines))));
        
        whiteLines = [];
        
        figure(3);
        imshow(bwCourt); hold on;
        
        %show detected lines
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            whiteLines = [whiteLines; xy(1,2) xy(1,1) xy(2,2) xy(2,1)];
            plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
        end
        
        pause;
        
        hold off;
        
        lineGroups = courtDetection_eliminate_line_outliers(courtImage, whiteLines, debugLineOutliers );
        
        whiteLines = [];
        
        figure(3);
        imshow(courtImage); hold on;
        
        for m=1:size(lineGroups, 1)
            whiteLines = [whiteLines; lineGroups(m, 4) lineGroups(m, 2) lineGroups(m, 5) lineGroups(m, 3)];
            plot(lineGroups(m, 2:3), lineGroups(m, 4:5), 'LineWidth',2,'Color','cyan');
        end
        
        hold off;
        pause;
    end
end
