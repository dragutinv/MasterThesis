function [detected_edges,detected_unprocessed_edges,strip_img] = ...
            analyse_image(params)
%        
% [detected_edges,detected_unprocessed_edges,strip_img] = ...
%           analyse_image(params)
%
% Detects vertical edges in the input image.
%
% INPUT:
% -------------------------------------------------------------------------
% params    - general parameters for edge detection 
%             (see params.rtf for details)
%
% OUTPUT:
% -------------------------------------------------------------------------
% detected_edges                - edges detected by algorithm
% detected_unprocessed_edges    - detected edges before post-processing
% strip_img                     - image consisting only of extracted strips
%
% Written by Inbal Horev, 2013.

C = params.C; 
if C==0
    detected_edges = cell(1,4);
    detected_unprocessed_edges = cell(1,4);
    strip_img = zeros(size(params.img));
    return;
end

% detect edges within strips
[v_strip_responses,sigma,strip_starts,strip_ends,strip_img] = calc_strip_responses(params);
params.sigma = sigma;
params.strip_starts = strip_starts;
params.strip_ends = strip_ends;

% matching continuous edges between strips
v_edges = cell(C-1,4);
v_edge_signs = cell(C-1,1);
for s = 1:(C-1)    
    [edges,v_edge_signs{s}] = analyze_pair(v_strip_responses(:,:,s),v_strip_responses(:,:,s+1),s,s+1,params);
    v_edges{s,1} = edges{1};
    v_edges{s,2} = edges{2};
    v_edges{s,3} = edges{3};
    v_edges{s,4} = edges{4};
end

detected_unprocessed_edges = cell(1,4);
for i = 1:(C-1)
    if (~isempty(v_edges{i,1}))
        detected_unprocessed_edges{1} = [detected_unprocessed_edges{1}; v_edges{i,1}];
        detected_unprocessed_edges{2} = [detected_unprocessed_edges{2}; v_edges{i,2}];
        detected_unprocessed_edges{3} = [detected_unprocessed_edges{3}; strip_starts(i)*ones(size(v_edges{i,1}))];
        detected_unprocessed_edges{4} = [detected_unprocessed_edges{4}; strip_ends(i+1)*ones(size(v_edges{i,1}))];
    end
end

% post processing
v_edges = supress_edges(v_edges,v_edge_signs,params);
v_edges = unify_edges(v_edges,params.L);
detected_edges = localize_edges(v_edges,params);