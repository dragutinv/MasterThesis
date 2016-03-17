#include "interpolate.h"

;void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {	
	double nprofiles=mxGetM(prhs[1]);

	double* x1=mxGetPr(prhs[1]);
	double* y1=mxGetPr(prhs[2]);
	double* x2=mxGetPr(prhs[3]);
	double* y2=mxGetPr(prhs[4]);
	
	double nrows=mxGetM(prhs[0]);
	double ncols=mxGetN(prhs[0]);
	double *ImPtr=mxGetPr(prhs[0]);

	double n = *mxGetPr(prhs[5]);

	plhs[0] = mxCreateDoubleMatrix( n, nprofiles, mxREAL );
	double *Out_ptr = mxGetPr(plhs[0]);
    int i,j;
	for (i = 0; i < nprofiles; i++) {
		mxArray* interp_data = interpolate(ImPtr, nrows, ncols, x1[i], y1[i], x2[i], y2[i], n);
		double *data_ptr = mxGetPr(interp_data);
		for (j = 0; j < n; j++) {
			Out_ptr[(int)(j + i*n)] = data_ptr[j];
		}		
	}
	plhs[1] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	Out_ptr =  mxGetPr(plhs[1]);
	Out_ptr[0] = nprofiles;
};
		

mxArray* interpolate(double* ImPtr, int nrows, int ncols, double x1, double y1, double x2, double y2, int n) {
	/*function F=LinesGetLinePt(x1,y1,x2,y2,im)
	0.31  624435    2 xd=(x1-x2); 
	0.32  624435    3 yd=(y1-y2); 
	0.33  624435    4 [nrows ncols]=size(im); 
	0.47  624435    5 di = sqrt(xd^2+yd^2); 
	0.44  624435    6 if (di<=sqrt(2)) 
	0.15   40412    7     F(1,1)=double(im(y1,x1)); 
	0.02   40412    8     if (x1~=x2 || y1~=y2 ); 
	0.05   24288    9     F(2,1)=double(im(y2,x2)); 
	0.01   24288   10     end 
	0.10   40412   11     return; 
				   12 end*/
	
	double xd=(x1-x2);
	double yd=(y1-y2);
	double di = sqrt(xd*xd+yd*yd);

	if (di<=sqrt(2.0)) {
		if (x1!=x2 || y1!=y2) {
			mxArray* data = mxCreateDoubleMatrix( 2, 1, mxREAL );
			double* Out_ptr=mxGetPr(data);
			Out_ptr[0]=ImPtr[(int) ((y1-1)+nrows*(x1-1))];
			Out_ptr[1]=ImPtr[ (int)((y2-1)+nrows*(x2-1))];
			return data;			
		} else {
			mxArray* data = mxCreateDoubleMatrix( 1, 1, mxREAL );
			double* Out_ptr= mxGetPr(data);
			Out_ptr[0]=ImPtr[ (int)((y1-1)+nrows*(x1-1))];
			return data;			
		}	
	}
	
	double *profiI = (double*)mxMalloc(2*n*sizeof(double));
	
	/*
	5.48  584023   19 profiI=[x1:(x2-x1)/(n-1):x2; y1:(y2-y1)/(n-1):y2]'; 
	0.40  584023   20 if (x1==x2) 
	0.34  244548   21     dd=profiI(:,1); 
	0.51  244548   22     profiI(:,1)=x1; 
	0.54  244548   23     profiI(:,2)=dd; 
	0.13  244548   24 end 
	0.37  584023   25 if (y1==y2) 
	0.16   50989   26     profiI(:,2)=y1; 
	0.03   50989   27 end */
	int addV=(int)n;
    int i;
	if (x1!=x2 && y1!=y2) {
		for (i=0;i<(int)n;i++) {	  
			profiI[i]=x1+(double)i*((x2-x1)/(n-1));
			profiI[(int)i+addV]=y1+(double)i*((y2-y1)/(n-1));
		}
	}
    
	if (x1==x2) {
		for (i=0;i<(int)n;i++) {
			profiI[i]=x1;
			profiI[(int)i+addV]=y1+(double)i*((y2-y1)/(n-1));
		}
		/* %profiI=[x1:(x2-x1)/(n-1):x2; y1:(y2-y1)/(n-1):y2]'; */
	}
	if (y1==y2) {
		for (i=0;i<(int)n;i++)  {
			profiI[i]=x1+(double)i*((x2-x1)/(n-1));
			profiI[(int)i+addV]=y1;
		}
	}
	
	/* Do the interp */
	/*	s = 1 + (profiI(:,1)-1)/(ncols-1)*(ncols-1); 
	1.45  584023   34 t = 1 + (profiI(:,2)-1)/(nrows-1)*(nrows-1); 
	2.39  584023   35 d = find(s==ncols); 
	1.67  584023   36 ndx = floor(t)+floor(s-1)*nrows;								- bilinear
					  ndx = floor(t)+floor(s-1)*(nrows+2);							- bicubic, no need for the change
	2.04  584023   37 s(:) = (s - floor(s)); 
	1.64  584023   38 if ~isempty(d), s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end		- bilinear
					  if ~isempty(d), s(d) = s(d)+1; ndx(d) = ndx(d)-nrows-2; end	- bicubic, no need for the change
	2.18  584023   39 d = find(t==nrows);  
	1.95  584023   40 t(:) = (t - floor(t)); 
	1.36  584023   41 if ~isempty(d), t(d) = t(d)+1; ndx(d) = ndx(d)-1; end */
	
	double * ndx= (double*)mxMalloc(n*sizeof(double));
	double * ndx_org= (double*)mxMalloc(n*sizeof(double));
	double * ndy= (double*)mxMalloc(n*sizeof(double));
	double * onemt= (double*)mxMalloc(n*sizeof(double));
	mxArray* data = mxCreateDoubleMatrix( n, 1, mxREAL );
	double *Out_ptr = mxGetPr(data);
	
	/*double * t= (double*)mxMalloc(n*sizeof(double));
	double * t0= (double*)mxMalloc(n*sizeof(double));
	double * t1= (double*)mxMalloc(n*sizeof(double));
	double * t2= (double*)mxMalloc(n*sizeof(double));
	
	double * s= (double*)mxMalloc(n*sizeof(double));
	double * s0= (double*)mxMalloc(n*sizeof(double));
	double * s1= (double*)mxMalloc(n*sizeof(double));
	double * s2= (double*)mxMalloc(n*sizeof(double));*/

	/* % Expand z so interpolation is valid at the boundaries.		- bicubic
	zz = zeros(size(arg3)+2);
	zz(1,2:ncols+1) = 3*arg3(1,:)-3*arg3(2,:)+arg3(3,:);
	zz(2:nrows+1,2:ncols+1) = arg3;
	zz(nrows+2,2:ncols+1) = 3*arg3(nrows,:)-3*arg3(nrows-1,:)+arg3(nrows-2,:);
	zz(:,1) = 3*zz(:,2)-3*zz(:,3)+zz(:,4);
	zz(:,ncols+2) = 3*zz(:,ncols+1)-3*zz(:,ncols)+zz(:,ncols-1);
	nrows = nrows+2; %also ncols = ncols+2;
	*/

	/*for(int y=0; y<ncols; y++ ) {
			ImPtr[(int) (y+nrows*(-1))] = 3*ImPtr[(int) y] - 3*ImPtr[(int) (y+nrows)] + ImPtr[(int) (y+nrows*2)];
			ImPtr[(int) (y+nrows*ncols)] = 3*ImPtr[(int) (y+nrows*(ncols-1))] - 3*ImPtr[(int) (y+nrows*(ncols-2))] + ImPtr[(int) (y+nrows*(ncols-3))];			
		}
		for( int x=-1; x<=nrows; x++ ) {
			ImPtr[(int) (-1+nrows*x)] = 3*ImPtr[(int) nrows*x] - 3*ImPtr[(int) (1+nrows*x)] + ImPtr[(int) (2+nrows*x)];
			ImPtr[(int) (ncols+nrows*x)] = 3*ImPtr[(int) ((ncols-1)+nrows*x)] - 3*ImPtr[(int) ((ncols-2)+nrows*x)] + ImPtr[(int) ((ncols-3)+nrows*x)];			
		}*/

	for (i=0;i<(int)n;i++) {
		/*s  */
		profiI[i]           = 1.0 + (profiI[i]-1) / (ncols-1)*(ncols-1); 		
		profiI[(int)i+addV] = 1.0 + (profiI[(int)i+addV]-1) / (nrows-1)*(nrows-1); 
		/*t */
		ndx_org[i] = floor(profiI[(int)i+addV])+floor(profiI[i]-1)*nrows; 
		ndx[i] = floor(profiI[i]-1); 
		ndy[i] = floor(profiI[(int)i+addV]); 
		if (profiI[i] == ncols) {
			profiI[i]=profiI[i]-floor(profiI[i]);
			profiI[i]=profiI[i]+1;
			ndx_org[i] =  ndx_org[i] - nrows;
			ndx[i] =  ndx[i] - 1;
		} else {
			profiI[i]=profiI[i]-floor(profiI[i]);
		}
		if (profiI[(int)i+addV] == nrows) {
			profiI[(int)i+addV]=profiI[(int)i+addV]-floor(profiI[(int)i+addV]);
			profiI[(int)i+addV] =profiI[(int)i+addV] +1;
			ndx_org[i] = ndx_org[i] - 1;
			ndy[i] =  ndy[i] - 1;
		} else {
			profiI[(int)i+addV]=profiI[(int)i+addV]-floor(profiI[(int)i+addV]);
		}	
		
		/* bilinear
			onemt = 1-t;
			F =  ( im(ndx).*(onemt) + im(ndx+1).*t ).*(1-s) + ...
			( im(ndx+nrows).*(onemt) + im(ndx+(nrows+1)).*t ).*s;		
		*/

		onemt[i]=1-profiI[(int)i+addV];

		Out_ptr[i]= (ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]))] * onemt[i] + 
			  ImPtr[(int) ((ndy[i])+nrows*(ndx[i]))] * profiI[(int)i+addV]) * (1-profiI[i]) + 
			  (ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]+1))] * onemt[i] + 
			  ImPtr[(int) ((ndy[i])+nrows*(ndx[i]+1))]  * profiI[(int)i+addV]) * profiI[i];
		
		/*	bicubic
		t0 = ((2-t).*t-1).*t;			
		t1 = (3*t-5).*t.*t+2;
		t2 = ((4-3*t).*t+1).*t;
		t(:) = (t-1).*t.*t;
		F     = ( zz(ndx).*t0 + zz(ndx+1).*t1 + zz(ndx+2).*t2 + zz(ndx+3).*t ) .* (((2-s).*s-1).*s);
		ndx(:) = ndx + nrows;
		F(:)  = F + ( zz(ndx).*t0 + zz(ndx+1).*t1 + zz(ndx+2).*t2 + zz(ndx+3).*t ) .* ((3*s-5).*s.*s+2);
		ndx(:) = ndx + nrows;
		F(:)  = F + ( zz(ndx).*t0 + zz(ndx+1).*t1 + zz(ndx+2).*t2 + zz(ndx+3).*t ) 
		ndx(:) = ndx + nrows;
		F(:)  = F + ( zz(ndx).*t0 + zz(ndx+1).*t1 + zz(ndx+2).*t2 + zz(ndx+3).*t ) .* ((s-1).*s.*s);
		F(:) = F/4;
		*/

		/*t0[i] = ((2 - profiI[(int)i+addV]) * profiI[(int)i+addV] - 1) * profiI[(int)i+addV];
		t1[i] = (3 * profiI[(int)i+addV] - 5) * profiI[(int)i+addV] * profiI[(int)i+addV] + 2;
		t2[i] = ((4 - 3*profiI[(int)i+addV]) * profiI[(int)i+addV] + 1) * profiI[(int)i+addV];
		t[i] =  (profiI[(int)i+addV] - 1) * profiI[(int)i+addV] * profiI[(int)i+addV];

		s0[i] = ((2 - profiI[(int)i]) * profiI[(int)i] - 1) * profiI[(int)i];
		s1[i] = (3 * profiI[(int)i] - 5) * profiI[(int)i] * profiI[(int)i] + 2;
		s2[i] = ((4 - 3*profiI[(int)i]) * profiI[(int)i] + 1) * profiI[(int)i];
		s[i] =  (profiI[(int)i] - 1) * profiI[(int)i] * profiI[(int)i];

		F[i]= (ImPtr[(int) ((ndy[i]-2)+nrows*(ndx[i]-1))] * t0[i] + 
			  ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]-1))] * t1[i] +
			  ImPtr[(int) ((ndy[i])+nrows*(ndx[i]-1))] * t2[i] +
			  ImPtr[(int) ((ndy[i]+1)+nrows*(ndx[i]-1))] * t[i]) * s0[i];

		F[i]+= (ImPtr[(int) ((ndy[i]-2)+nrows*(ndx[i]))] * t0[i] + 
			   ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]))] * t1[i] +
			   ImPtr[(int) ((ndy[i])+nrows*(ndx[i]))] * t2[i] +
			   ImPtr[(int) ((ndy[i]+1)+nrows*(ndx[i]))] * t[i]) * s1[i];

		F[i]+= (ImPtr[(int) ((ndy[i]-2)+nrows*(ndx[i]+1))] * t0[i] + 
			   ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]+1))] * t1[i] +
			   ImPtr[(int) ((ndy[i])+nrows*(ndx[i]+1))] * t2[i] +
			   ImPtr[(int) ((ndy[i]+1)+nrows*(ndx[i]+1))] * t[i]) * s2[i];

		F[i]+= (ImPtr[(int) ((ndy[i]-2)+nrows*(ndx[i]+2))] * t0[i] + 
			   ImPtr[(int) ((ndy[i]-1)+nrows*(ndx[i]+2))] * t1[i] +
			   ImPtr[(int) ((ndy[i])+nrows*(ndx[i]+2))] * t2[i] +
			   ImPtr[(int) ((ndy[i]+1)+nrows*(ndx[i]+2))] * t[i]) * s[i];
				
		F[i] = F[i] / 4;*/

	}
	return data;
}