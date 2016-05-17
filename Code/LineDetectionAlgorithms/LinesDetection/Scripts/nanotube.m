
% Creates figure 7.3 of the paper
%
% Written by Inbal Horev, 2014

os = computer('arch');
if strcmp(os,'maci64') || strcmp(os,'glnxa64')
    addpath('../LSD');
    addpath('../Sublinear');
    
    I = double(imread('../Images/nanotube.tif'))/255;
else
    addpath('..\Sublinear');
    
    I = double(imread('..\Images\nanotube.tif'))/255;
end

% -------------------------------------------------------------------------
disp('Canny');
tic();
cannyDetections = edge(I,'canny',[0.2 0.5]);
runtime = toc();
cannyDetectionsOverlay = overlay_edges(I,cannyDetections);
disp(['Runtime: ', num2str(runtime),' sec']);

figure(); title('Canny'); imshow(cannyDetectionsOverlay);

% -------------------------------------------------------------------------
if strcmp(os,'maci64')
    disp('LSD');
    tic();
    lsdEdgeList = lsd_mex(I);
    runtime = toc();
    edges{1} = lsdEdgeList(2,:);
    edges{2} = lsdEdgeList(4,:);
    edges{3} = lsdEdgeList(1,:);
    edges{4} = lsdEdgeList(3,:);
    [lsdDetections,~,lsdDetectionsOverlay] = visualise_edges(I,edges,cell(1,4));
    disp(['Runtime: ', num2str(runtime),' sec']);

    figure(); title('LSD'); imshow(lsdDetectionsOverlay);
end

% -------------------------------------------------------------------------
C = [0 6];
j = 5;
w = 3;
sigma = NaN;
alpha_s = 0.5;
[~,~,detectionsOverlay,~,~,NoPostProcessingDetectionsOverlay,~,~,runtime] = ...
    sublinear_edge_detection(I,sigma,j,C,w,alpha_s);

figure(); title('SubLinear with no Post Processing'); imshow(detectionsOverlay);
figure(); title('SubLinear'); imshow(detectionsOverlay);

disp(['Runtime: ', num2str(runtime),' sec']);

