#include "math.h"
#include "string.h"
#include "matrix.h"
#include "mex.h"

void mean_convolve(double* data_in, double* data_out, int n, int k);
double calc_sum(double* data, int a, int b);
double get_log_likelihood(double* profile1, double* profile2, int n);
