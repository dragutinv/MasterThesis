close all;
clear all;

folderModels = './InputData/VideoMatches/';

%debug options
debug_backgorund = 1;

vidCourtModels = dir(strcat(folderModels, '*.mp4'));
for i = 2 : length(vidCourtModels)
    videoMatchSrc = strcat(folderModels, vidCourtModels(i).name);
    videoMatch = VideoReader(videoMatchSrc);
    
    numFrame=0;
    while hasFrame(videoMatch)
        imgVideoFrame = readFrame(videoMatch);
        grayFrame = rgb2gray(imgVideoFrame);
        hsvFrame = rgb2hsv(imgVideoFrame);
        
        %DETECT BALL
        hueThresholdLow = 0.1;
        hueThresholdHigh = 0.5;
        valueThresholdLow = 0.6;
        valueThresholdHigh = 0.9;
        
        imgFrameHue = hsvFrame(:, :, 1); %Separate hue
        imgFrameSat = hsvFrame(:, :, 2); %Separate saturation
        imgFrameVal = hsvFrame(:, :, 3); %Separate value
        
        hueMask = (imgFrameHue >= hueThresholdLow) & (imgFrameHue <= hueThresholdHigh);
        valueMask = (imgFrameVal >= valueThresholdLow) & (imgFrameVal <= valueThresholdHigh);
        yellowObject = uint8(hueMask & valueMask);
        
        %yellowObject = imerode(yellowObject, strel('disk', 2)); %remove small components
        yellowObject = imfill(yellowObject, 'holes');
        
        %check if this frame contains whole field
        [nrows, ncols] = size(grayFrame);
        centerRows = uint16(nrows/2);
        centerCols = uint16(ncols/2);
        
        entropyV = entropy(grayFrame((centerRows-100):(centerRows+100), (centerCols-50):(centerCols+50)));
        %non field shot
        if entropyV > 5.2
            %continue;
        end
        
        if numFrame == 2
            %find frame difference
            frmDifference = (grayFrame-prevFrame) > 25;
            frmDifference = imfill(frmDifference,'holes');
            
            detectedBall = frmDifference & yellowObject;
            
            props = regionprops(frmDifference, 'Area', 'Centroid', 'Image', 'BoundingBox');
            
            %min and max radius
            minBall = 3;
            maxBall = 50;
            
            imshow(frmDifference);
            hold on;
            
            for j=1:size(props)                
                if props(j).Area >= minBall && props(j).Area <= maxBall
                    %check position
                    if props(j).Centroid(1) >= (0.1 * ncols) && props(j).Centroid(1) <= (0.9 * ncols) && ...
                            props(j).Centroid(2) >= (0.1 * nrows) && props(j).Centroid(2) <= (0.9 * nrows)
                        
                        
                        %check color
                        ballCandidate = hsvFrame(props(j).Centroid(2)-2:props(j).Centroid(2)+2, props(j).Centroid(1)-2:props(j).Centroid(1)+2, :);
                        
                        t = text(props(j).Centroid(1), props(j).Centroid(2), num2str(mean2(ballCandidate(:,:,1))));
                        t.FontSize = 12;
                        t.Color = 'magenta';
                        
                        if (mean2(ballCandidate(:,:,1)) < 0.3)
                            plot(props(j).Centroid(1), props(j).Centroid(2), 'bo');
                            rectangle('Position', props(j).BoundingBox, 'EdgeColor', 'y', 'Curvature', 1, 'LineWidth', 2);
                        end
                    end
                end
            end
            
            hold off;
            
            pause;
            numFrame = 0;
        end
        
        if numFrame == 0
            prevFrame = grayFrame;
        end
        
        numFrame = numFrame+1;
    end
end
