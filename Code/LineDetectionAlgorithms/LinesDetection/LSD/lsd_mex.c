#include <stdio.h>
#include <stdlib.h>
#include "lsd.h"
#include "mex.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  double * img = mxGetPr(prhs[0]);
  double * out;
  double * out_ptr;
  int i,j,n;
  int X = (int)mxGetM(prhs[0]);
  int Y = (int)mxGetN(prhs[0]);

  double scale = 0.8;
  double sigma_scale = 0.6; /* Sigma for Gaussian filter is computed as
                                sigma = sigma_scale/scale.                    */
  double quant = 0.0;       /* Bound to the quantization error on the
                                gradient norm.                                */
  double ang_th = 22.5;     /* Gradient angle tolerance in degrees.           */
  double log_eps = 0.0;     /* Detection threshold: -log10(NFA) > log_eps     */
  double density_th = 0.7;  /* Minimal density of region points in rectangle. */
  int n_bins = 1024;        /* Number of bins in pseudo-ordering of gradient
                               modulus.  */


  /* LSD call */

  out = LineSegmentDetection( &n, img, X, Y, scale, sigma_scale, quant,
                               ang_th, log_eps, density_th, n_bins,
                               NULL, NULL, NULL );
  /*out = lsd(&n,img,X,Y);*/

  plhs[0] = mxCreateDoubleMatrix( 7, n, mxREAL ); 
  out_ptr = mxGetPr(plhs[0]);
  
  for (i = 0; i < n; i++)
	for (j = 0; j < 7; j++)
		out_ptr[7*i + j] = out[7*i + j];
  
  return;
}
