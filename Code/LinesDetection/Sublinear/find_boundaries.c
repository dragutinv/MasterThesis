#include "find_boundaries.h"

;void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {	
	
	double *original_boundaries= mxGetPr(prhs[0]);
	int top = (int)original_boundaries[0];
	int bottom = (int)original_boundaries[1];

	double *d_x= mxGetPr(prhs[1]);
	double d_x1 = d_x[0];
	double d_x2 = d_x[1];
	
	double *pixel_responses = mxGetPr(prhs[2]);
	int n = (int)mxGetM(prhs[2]);
		
	int k = 5;

	double *segment_responses = (double*)mxMalloc((n-k+1)*sizeof(double));
	mean_convolve(pixel_responses,segment_responses,n,k);
	
	double* edge = (double*)mxMalloc((int)n*sizeof(double));
	double edge_strength;	
	double* response_profile = (double*)mxMalloc((n-k+1)*sizeof(double));
	double ll;	
	double min_ll,min_t, min_b;

	min_ll = calc_sum(segment_responses,0,(n-k+1));
	min_ll *= min_ll;
	memset(edge,0,n*sizeof(double));

    int t,b,i;
	for (t = (int)d_x1-1; t >= 0; t--) {
		edge_strength = calc_sum(pixel_responses,t,bottom)/(bottom-t);
		for (i = t; i <= bottom; i++) {
			edge[i] = edge_strength;
		}
		mean_convolve(edge,response_profile,n,k);
		ll = get_log_likelihood(segment_responses,response_profile,(n-k+1));
		if (ll < min_ll) {
			min_ll = ll;
			min_t = t;
		}
	}

	min_ll = calc_sum(segment_responses,0,(n-k+1));
	min_ll *= min_ll;
	memset(edge,0,n*sizeof(double));
    
	for (b = (int)(n-d_x2-1); b < n; b++) {
		edge_strength = calc_sum(pixel_responses,(int)min_t,b)/(b-(int)min_t);
		for (i = (int)min_t; i <= b; i++) {
			edge[i] = edge_strength;
		}		
		mean_convolve(edge,response_profile,n,k);
		ll = get_log_likelihood(segment_responses,response_profile,(n-k+1));
		if (ll < min_ll) {
			min_ll = ll;
			min_b = b;
		}
	}

	// re-iterating because now there is a better estimate of the edge strength
	min_ll = calc_sum(segment_responses,0,(n-k+1));
	min_ll *= min_ll;
	memset(edge,0,n*sizeof(double));
	for (t = (int)d_x1-1; t >= 0; t--) {
		edge_strength = calc_sum(pixel_responses,t,(int)min_b)/((int)min_b-(int)t);
		for (i = t; i <= (int)min_b; i++) {
			edge[i] = edge_strength;
		}
		mean_convolve(edge,response_profile,n,k);
		ll = get_log_likelihood(segment_responses,response_profile,(n-k+1));
		if (ll < min_ll) {
			min_ll = ll;
			min_t = t;
		}
	}

	plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	double *out_ptr =  mxGetPr(plhs[0]);
	out_ptr[0] = (int)min_t;
	plhs[1] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	out_ptr =  mxGetPr(plhs[1]);
	out_ptr[0] = (int)min_b;
}

;void mean_convolve(double* data_in, double* data_out, int n, int k) {
	
	double sum = 0;
    int i;
	for (i = 0; i < k; i++) {
		sum += data_in[i];
	}
	data_out[0] = sum/k;

	for (i = 0; i < (n-k); i++) {
		sum += data_in[i+k]-data_in[i];
		data_out[i+1] = sum/k;
	}	
}

;double calc_sum(double* data, int a, int b) {
	double s = 0;
    int i;
	for (i = a; i < b+1; i++) {
		s += data[i];
	}
	return s;
}
	
;double get_log_likelihood(double* profile1, double* profile2, int n) {
	double ll = 0;
    int i;
	for (i = 0; i < n; i++) {
		ll += (profile1[i] - profile2[i])*(profile1[i] - profile2[i]);
	}
	return ll;
}