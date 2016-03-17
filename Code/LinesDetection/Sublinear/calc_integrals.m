function integrals = calc_integrals(img)
% integrals = calc_integrals(img)
% 
% Calculates line integrals of dyadic length at angles <=pi/4 
% (in absolute value) w.r.t the vertical axis
%
% INPUT:
% -------------------------------------------------------------------------
% img           - input image
%
% OUPUT:
% -------------------------------------------------------------------------
% integrals     - computed line integrals
%
% Written by Ronen Basri, 2012.

width = size(img,2);
height = size(img,1);
len = 1;

% initialization, vertical orientations
Vnew = zeros(height-1,width,3);
Vnew(:,2:end,1)   = 0.5 * (img(1:end-1,2:end) + img(2:end,1:end-1));
Vnew(:,:,2)       = 0.5 * (img(1:end-1,:) + img(2:end,:));
Vnew(:,1:end-1,3) = 0.5 * (img(1:end-1,1:end-1) + img(2:end,2:end));

Vprev = Vnew;

% vertical orientations
while size(Vprev,1) > 1
    len = 2*len;
    T = 2*len + 1;

    Vnew = zeros(size(Vprev,1)-1,width,T);
        
    % sum pairs along the vertical orientation
    Vnew(:,:,len+1) = 0.5 * (Vprev(1:end-1,:,len/2+1) + Vprev(2:end,:,len/2+1));
    
    for t = 1:len/2
        % sum pairs along same orientation
        t2 = 2*t;
        tpos2 = len + 1 + t2;
        tpos = len/2 + 1 + t;
        tneg2 = len + 1 - t2;
        tneg = len/2 + 1 - t;
        Vnew(:,t2+1:end,tneg2) = 0.5 * (Vprev(1:end-1,t2+1:end,tneg) + Vprev(2:end,t+1:end-t,tneg));
        Vnew(:,1:end-t2,tpos2) = 0.5 * (Vprev(1:end-1,1:end-t2,tpos) + Vprev(2:end,t+1:end-t,tpos));

        % New orientations: parallelogram rule
        t2 = 2*t-1;
        tpos2 = len + 1 + t2;
        tpos = len/2 + 1 + t;
        tneg2 = len + 1 - t2;
        tneg = len/2 + 1 - t;
        Vnew(:,t2+1:end,tneg2) = 0.25 * (Vprev(1:end-1,t2+1:end,tneg) + Vprev(1:end-1,t2+1:end,tneg+1) +...  
                                        Vprev(2:end,t:end-t,tneg+1) + Vprev(2:end,t+1:end-t+1,tneg));
        Vnew(:,1:end-t2,tpos2) = 0.25 * (Vprev(1:end-1,1:end-t2,tpos-1) + Vprev(1:end-1,1:end-t2,tpos) +...  
                                        Vprev(2:end,t+1:end-t+1,tpos-1) + Vprev(2:end,t:end-t,tpos));
    end

    Vprev = Vnew(1:2:end,:,:);    
    
end
% we're only keeping integrals which go all the way across our data
integrals = squeeze(Vprev);