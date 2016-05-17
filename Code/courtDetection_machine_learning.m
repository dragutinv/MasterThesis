close all;
clear all;

training = 0;
detection = 1;

if training == 1
    
    load('positiveInstances.mat');
    
    imDir = fullfile('./InputData/CourtModels');
    addpath(imDir);
    
    negativeFolder = fullfile('./InputData/NonCourtImages');
    
    trainCascadeObjectDetector('cornerDetectors.xml', positiveInstances, negativeFolder, 'FeatureType', 'Haar', 'FalseAlarmRate',0.2,'NumCascadeStages',10);
end

if detection == 1
    folderModels = './InputData/TestCourtImages/';
    detector = vision.CascadeObjectDetector('cornerDetectors.xml');
    
    imgCourtModels = dir(strcat(folderModels, '*.jpg'));
    for i = 1 : length(imgCourtModels)
        courtModel = strcat(folderModels, imgCourtModels(i).name);
        courtImage = imread(courtModel);
        
        
        bbox = step(detector,courtImage);
        detectedImg = insertObjectAnnotation(courtImage,'rectangle',bbox,'Corner');
        figure (1);
        imshow(detectedImg);
        pause;
    end
    
end