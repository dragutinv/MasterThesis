function [ lineGroups ] = courtDetection_eliminate_line_outliers(segmentedCourt, whiteLines, debug )
%COURTDETECTION_ELIMINATE_LINE_OUTLIERS Summary of this function goes here

lineGroups = [];

%eliminate outliers
for k = 1:size(whiteLines,1)
    counter=0;
    
    x =[whiteLines(k, 2) whiteLines(k, 4)];
    y =[whiteLines(k, 1) whiteLines(k, 3)];
    
    lineAngle = atan2d(y(2)-y(1), x(2) - x(1));
    
    [courtHeight, courtWidth, ~] = size(segmentedCourt);
    
    if (lineAngle < 10 || lineAngle > 170)
        %disp('Horizontal line');
        orientation = 0; %'horizontal';
        minParalelLines = 2;
        maxAngleDiff = 1;
        minLineLength = 0.03*courtWidth;
        minLineDistance = 20;
        maxLineDistance = 0.8*courtHeight;
    else
        %disp('Vertical line');
        orientation = 1; %'vertical';
        minParalelLines = 1;
        maxAngleDiff = 15;
        minLineLength = 0.1*courtHeight;
        minLineDistance = 0.03*courtWidth;
        maxLineDistance = 0.08*courtWidth;
    end
    
    lineLength = sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2);
    if lineLength < minLineLength
        continue;
    end
    
    for l=1:size(whiteLines,1)
        
        if l ~= k
            x1 =[whiteLines(l, 2) whiteLines(l, 4)];
            y1 =[whiteLines(l, 1) whiteLines(l, 3)];
            
            lineRefLength = sqrt((x1(2)-x1(1))^2 + (y1(2)-y1(1))^2);
            
            lineRefAngle = atan2d(y1(2)-y1(1), x1(2) - x1(1));
            
            if lineRefLength < minLineLength
                continue;
            end
            
            %find distance between lines
            m = (y(2)-y(1)) / (x(2)-x(1));
            b = y(1) - m*x(1);
            lineDistance = abs((m*x1(1)-y1(1) + b)/sqrt(m^2+1));
            
            angleDiff = abs(diff([abs(lineAngle), abs(lineRefAngle)]));
            
            if (angleDiff > 90)
                angleDiff = 180 - angleDiff;
            end
            
            if debug.debugParalelLines == 1
                figure(3);
                imshow(segmentedCourt); hold on;
                disp('-----');
                disp(strcat('Angle difference:', num2str(angleDiff)));
                disp(strcat('Line distance:', num2str(lineDistance)));
                plot(x, y, 'LineWidth',2,'Color','blue');
                plot(x1, y1, 'LineWidth',2,'Color','red');
                hold off;
                pause;
            end
            
            if  angleDiff <= maxAngleDiff && lineDistance >= minLineDistance && lineDistance <= maxLineDistance
                counter = counter + 1;
                
                if debug.debugParalelLines == 1
                    disp(strcat('Matched lines:', num2str(counter)));
                end
                
                %accept the line, and store the line in group of
                %similar lines
                if (counter == minParalelLines)
                    %find the distance between current line and all other lines in lineGroups
                    %in order to merge close lines
                    
                    if debug.debugParalelLines == 1
                        figure(3);
                        imshow(segmentedCourt); hold on;
                        plot(x, y, 'LineWidth',2,'Color','green');
                        hold off;
                        pause;
                    end
                    
                    if (isempty(lineGroups))
                        lineGroups = [lineGroups; orientation, x, y];
                    else
                        distanceFromLines = abs((m*lineGroups(:,2) - lineGroups(:,4) + b)/sqrt(m^2+1));
                        
                        %find closest line
                        groupId =[];
                        groupsId = find(distanceFromLines < 8);
                        
                        if (isempty(groupsId) == 0)
                            %find only line with the same orientation
                            id = find(lineGroups(groupsId,1) == orientation);
                            groupsId = groupsId(id);
                        end
                        
                        if (isempty(groupsId))
                            lineGroups = [lineGroups; orientation, x, y];
                        else
                            %merge segments
                            for r = 1: size(groupsId, 1)
                                groupId = groupsId(r);
                                
                                refX = lineGroups(groupId, 2:3);
                                refY = lineGroups(groupId, 4:5);
                                
                                if (debug.debugMergeLines == 1)
                                    figure(3);
                                    imshow(segmentedCourt); hold on;
                                    
                                    plot(x, y, 'LineWidth', 2, 'Color', 'cyan');
                                    for m=1:size(lineGroups, 1)
                                        plot(lineGroups(m, 2:3), lineGroups(m, 4:5), 'LineWidth',2,'Color','red');
                                    end
                                    hold off;
                                    pause;
                                end
                                
                                if lineAngle > 90
                                    lineGroups(groupId, 2) = min([refX x]);
                                    lineGroups(groupId, 3) = max([refX x]);
                                    lineGroups(groupId, 4) = max([refY y]);
                                    lineGroups(groupId, 5) = min([refY y]);
                                else
                                    lineGroups(groupId, 2) = min([refX x]);
                                    lineGroups(groupId, 3) = max([refX x]);
                                    lineGroups(groupId, 4) = min([refY y]);
                                    lineGroups(groupId, 5) = max([refY y]);
                                end
                                
                                x = lineGroups(groupId, 2:3);
                                y = lineGroups(groupId, 4:5);
                            end
                        end
                    end
                    
                    if (debug.debugMergeLines == 1)
                        figure(3);
                        imshow(segmentedCourt); hold on;
                        
                        for m=1:size(lineGroups, 1)
                            plot(lineGroups(m, 2:3), lineGroups(m, 4:5), 'LineWidth',2,'Color','cyan');
                        end
                        
                        pause;
                    end
                    
                    break;
                end
            end
        end
        
    end
end

end

