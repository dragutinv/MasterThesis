function [F,P,R] = fMeasure(im,gt)
    
    [~,cntR,sumR,cntP,sumP] = boundaryPRfast4SNR(im,gt,1);
    R = cntR./(sumR + (sumR == 0));
    P = cntP./(sumP + (sumP == 0));
    F = 2*P.*R./(P+R+((P+R)==0));
end