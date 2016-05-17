#include <math.h>
#include <string.h>
#include "matrix.h"
#include "mex.h"

mxArray* interpolate(double* ImPtr, int nrows, int ncols, double x1, double y1, double x2, double y2, int n);
