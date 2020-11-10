#include<stdio.h>
#include<stdlib.h>

#define STR(x) #x
#define MACRO_EXPANSION(x) STR(x)

#define ORDER 10
#define NT (ORDER + 1) /// number of coeffs
#define NB 11 /// number of bits

#ifndef BIT_LOSS
#pragma message("BIT_LOSS definition not found")
#define BIT_LOSS NB
#else
#pragma message("Definition found: BIT_LOSS=" MACRO_EXPANSION(BIT_LOSS))
#endif

//const int b[NT]={8, 17, 8}; /// b array
//const int a[NT-1]={-147, 52}; /// a array
int b[NT];
int a[NT-1];

#ifdef ADDER_ANALYZE
int min_p=1023;
int max_p=-1024;
int min_y=1023;
int max_y=-1024;
#endif

/// Perform fixed point filtering assming direct form I
///\param x is the new input sample
///\return the new output sample
#ifdef ADDER_ANALYZE
int myfilter(int x, int j)
#else
int myfilter(int x)
#endif
{
  static int sx[NT]; /// x shift register
  static int sy[NT-1]; /// y shift register
  static int first_run = 0; /// for cleaning shift registers
  int i; /// index
  int y; /// output sample
  #ifdef ADDER_ANALYZE
  int prod, prod_trunc;
  FILE *fp_stdout;
  fp_stdout = fopen("/dev/stdout","a");
  #endif

  /// clean the buffers
  if (first_run == 0)
  {
    first_run = 1;
    for (i=0; i<NT; i++)
      sx[i] = 0;
    for (i=0; i<NT-1; i++)
      sy[i] = 0;
  }

  /// shift and insert new sample in x shift register
  for (i=NT-1; i>0; i--)
    sx[i] = sx[i-1];
  sx[0] = x;

  /// make the convolution
  /// Moving average part
  y = 0;
  #ifdef ADDER_ANALYZE
  	fprintf(fp_stdout,"SAMPLE_N = %d\n", j);
  #endif
  for (i=0; i<NT; i++) {
  	y += (sx[i]*b[i]) >> (BIT_LOSS);
  	#ifdef ADDER_ANALYZE
  	prod = (sx[i]*b[i]);
  	prod_trunc = (prod >> (BIT_LOSS));
  	fprintf(fp_stdout,"ITER: %d\n\tsample = %d\tcoeff = %d\n\ts*b %d\ts*b_trunc = %d\t=> y = %d\n", i, sx[i], b[i], prod, prod_trunc, y);
  	if (prod_trunc > max_p) {
  		max_p = prod_trunc;
  	}
  	if (prod_trunc < min_p) {
  		min_p = prod_trunc;
  	}
  	if (y > max_y) {
  		max_y = y;
  	}
  	if (y < min_y) {
  		min_y = y;
  	}
  	#endif
  }
  #ifdef ADDER_ANALYZE
  	fprintf(fp_stdout,"\n\n");
  #endif

  /// Auto regressive part
  #ifdef IIR
  for (i=0; i<NT-1; i++)
    y -= (sy[i]*a[i]) >> (BIT_LOSS);
  #endif

  /// update the y shift register
  for (i=NT-2; i>0; i--)
    sy[i] = sy[i-1];
  sy[0] = y;
 
  #ifdef ADDER_ANALYZE
  fclose(fp_stdout);
  #endif
 
  return y;
}

int main (int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;
  FILE *fp_coeff;
  
  int i=0;

  int x;
  int y;
  #ifdef ADDER_ANALYZE
  int j=1;
  #endif

  /// check the command line
  if (argc != 4)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  // input samples
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n", argv[1]);
    exit(2);
  }
  // coeffs
  fp_coeff = fopen(argv[2], "r");
  if (fp_coeff == NULL ) {
    printf("Error: cannot open %s\n", argv[2]);
    exit(3);
  }
  do{
    fscanf(fp_coeff, "%d", &b[i]);
    a[i]=0;
    i++;
  } while (!feof(fp_coeff));
  
  fp_out = fopen(argv[3], "w");

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do{
    #ifdef ADDER_ANALYZE
    y = myfilter(x,j);
    #else
    y = myfilter(x);
    #endif
    fprintf(fp_out,"%d\n", y);
    fscanf(fp_in, "%d", &x);
    #ifdef ADDER_ANALYZE
    j++;
    #endif
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);
  #ifdef ADDER_ANALYZE
  FILE *fp_stdout;
  fp_stdout = fopen("/dev/stdout","a");
  fprintf(fp_stdout,"max_p = %d, min_p = %d\n", max_p, min_p);
  fprintf(fp_stdout,"max_y = %d, min_y = %d\n", max_y, min_y);
  fclose(fp_stdout);
  #endif

  return 0;

}
