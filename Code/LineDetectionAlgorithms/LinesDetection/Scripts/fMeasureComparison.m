
% Creates Figure 7.1 of the paper
%
% Written by Inbal Horev, 2014

os = computer('arch');
if strcmp(os,'maci64') || strcmp(os,'glnxa64')
    addpath('../SubLinear');
    addpath('../LSD');
    addpath('../segbench/Benchmark');
    addpath('../segbench/lib/matlab/')

    I0 = double(imread('../Images/test_img.tif'))/255;
else
    addpath('..\SubLinear');
    
    addpath('..\segbench\Benchmark');
    addpath('..\segbench\lib\matlab')
    
    I0 = double(imread('..\Images\test_img.tif'))/255;
end

filename = 'fmeasureComparison.mat';
if exist(filename,'file')
    load(filename);
else
    CURRENT_ITER = 1;
    MAX_ITERS = 10;
    SNRS = [3 2.5 2 1.5 1.25 1:-0.1:0.2];
    
    % methods:  Canny, LSD, sub-linear w/o post-processing, sub-linear
    % LSD runs only on linux/unix systems.
    if strcmp(os,'maci64') || strcmp(os,'glnxa64')
        numMethods = 4;
    else
        numMethods = 3;
    end
    fMeasures = zeros(numel(SNRS),numMethods);
end


groundTruth = edge(I0,'canny');
gt = cell(1,1);
gt{1} = groundTruth;

while CURRENT_ITER <= MAX_ITERS
    Inoise = randn(size(I0));
    for i_snr = 1:length(SNRS)
        % creating the image
        sigma = 1/SNRS(i_snr);
        I = I0 + sigma*Inoise;
        min_v = min(I(:));
        max_v = max(I(:));
        I = (I - min_v)/(max_v - min_v);
        sigma = sigma/(max_v - min_v);
        
        disp(['ITER: ',num2str(CURRENT_ITER),', SNR: ',num2str(SNRS(i_snr))]);
        
        % Canny        
        cannyDetections = edge(I,'canny',[0.4 0.7]);
        [~,~,fCanny] = fMeasure(cannyDetections,gt);
        
        % LSD
        lsdEdgeList = lsd_mex(I);
        edges{1} = lsdEdgeList(2,:);
        edges{2} = lsdEdgeList(4,:);
        edges{3} = lsdEdgeList(1,:);
        edges{4} = lsdEdgeList(3,:);        
        lsdDetections = visualise_edges(I,edges,cell(1,4));
        [~,~,fLSD] = fMeasure(lsdDetections,gt);
                
        % sub-linear with and w/o post processing
        C = 5;
        w = 3;
        j = 6;        
        
        [subLinearDetections,~,~,subLinearNoPostProcessingDetections,~,~,~,~,runtime] = ...
                sublinear_edge_detection(I,sigma,j,C,w);
        fSubLinearNoPostProcessing = fMeasure(subLinearNoPostProcessingDetections>0,gt);
        fSubLinear = fMeasure(subLinearDetections>0,gt);           
        
        F = [fCanny fLSD fSubLinearNoPostProcessing fSubLinear];
        if CURRENT_ITER == 1
            fMeasures(i_snr,:) = F;
        else
            fMeasures(i_snr,:) = (fMeasures(i_snr,:)*(CURRENT_ITER-1) + F)/CURRENT_ITER;
        end    
                    
    end
    CURRENT_ITER = CURRENT_ITER + 1;
    save(filename,'CURRENT_ITER','MAX_ITERS','SNRS','fMeasures');
end

% create the figure
markerSize = 15;
fontSize = 20;
figure();
hold on;
plot(SNRS,fMeasures(:,1),'bo-','LineWidth',2,'MarkerSize',markerSize);
if strcmp(os,'maci64') || strcmp(os,'glnxa64')
    plot(SNRS,fMeasures(:,2),'kx-','LineWidth',2,'MarkerSize',markerSize);
    plot(SNRS,fMeasures(:,3),'gs-','LineWidth',2,'MarkerSize',markerSize);
    plot(SNRS,fMeasures(:,4),'md-','LineWidth',2,'MarkerSize',markerSize);
else
    plot(SNRS,fMeasures(:,2),'gs-','LineWidth',2,'MarkerSize',markerSize);
    plot(SNRS,fMeasures(:,3),'md-','LineWidth',2,'MarkerSize',markerSize);
end
xlim([SNRS(end) SNRS(1)])
grid on
set(gca,'FontSize',fontSize)
if strcmp(os,'maci64') || strcmp(os,'glnxa64')
    legend({'Canny','LSD','SubLinear w/o PostProcessing','SubLinear'},4);
else
    legend({'Canny','SubLinear w/o PostProcessing','SubLinear'},4);
end
xlabel('SNR')
ylabel('F-measure')
