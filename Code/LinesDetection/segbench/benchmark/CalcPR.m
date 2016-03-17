function [P,R,F] = CalcPR(im,gt)

    gtt = cell(1,1);
    gtt{1} = gt;
    [~,cntR,sumR,cntP,sumP] = boundaryPRfast4SNR(im,gtt,1);
    R = cntR./(sumR + (sumR == 0));
    P = cntP./(sumP + (sumP == 0));
    F = fmeasure(R,P);
end

function f = fmeasure(r,p)
    f = 2*p.*r./(p+r+((p+r)==0));
end