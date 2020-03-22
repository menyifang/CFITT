/*
Andriy Myronenko
 */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "mex.h"
#define	max(A, B)	((A) > (B) ? (A) : (B))
#define	min(A, B)	((A) < (B) ? (A) : (B))

void cpd_comp(
		double* x,
		double* y, 
        double* sigma2,
		double* outlier,
        double* P,
        int N,
		int M,
        int D
        )

{
  int		n, m, d,itre;
  double	ksig, diff, razn, outlier_tmp, sp,pmn;

  ksig = -2.0 * *sigma2;
  outlier_tmp=(*outlier*M*pow (-ksig*3.14159265358979,0.5*D))/((1-*outlier)*N); 
 /* printf ("ksig = %lf\n", *sigma2);*/
  /* outlier_tmp=*outlier*N/(1- *outlier)/M*(-ksig*3.14159265358979); */
  
  // X,j
  itre = 0;
  for (n=0; n < N; n++) 
  {    
      sp=0;
      for (m=0; m < M; m++)//Y,i 
      {
          razn=0;
          for (d=0; d < D; d++) 
          {
             diff = (*(x+n+d*N))- (*(y+m+d*M));  
             diff = diff*diff;
             razn += diff;
          }
          pmn = exp(razn/ksig);
          *(P+itre) = pmn;
          sp += pmn;
          //next point
          itre++;
      }
      
      itre = itre-M;
      for (m=0; m < M; m++)//Y,i 
      {
          pmn = *(P+itre);
          *(P+itre) = pmn/(sp+outlier_tmp);
          //next point
          itre++;
      }      
            
  }

  return;
}

/* Input arguments */
#define IN_x		prhs[0]
#define IN_y		prhs[1]
#define IN_sigma2	prhs[2]
#define IN_outlier	prhs[3]

/* Output arguments */
#define OUT_P1		plhs[0]

/* Gateway routine */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  double *x, *y, *sigma2, *outlier, *P1, *Pt1, *Px, *E;
  int     N, M, D;
  
  /* Get the sizes of each input argument */
  N = mxGetM(IN_x);
  M = mxGetM(IN_y);
  D = mxGetN(IN_x);
  
  /* Create the new arrays and set the output pointers to them */
  OUT_P1     = mxCreateDoubleMatrix(M, N, mxREAL);

    /* Assign pointers to the input arguments */
  x      = mxGetPr(IN_x);
  y       = mxGetPr(IN_y);
  sigma2       = mxGetPr(IN_sigma2);
  outlier    = mxGetPr(IN_outlier);

 
  
  /* Assign pointers to the output arguments */
  P1      = mxGetPr(OUT_P1);
   
  /* Do the actual computations in a subroutine */
  cpd_comp(x, y, sigma2, outlier, P1, N, M, D);
  
  return;
}


