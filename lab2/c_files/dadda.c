#include <stdio.h>
#include <stdlib.h>

//defining ANSI colors
#define C_GREEN "\x1b[1;32m"
#define C_YELLOW "\x1b[1;33m"
#define C_CYAN "\x1b[1;36m"
#define C_WHITE "\x1b[1;37m"
#define C_RESET "\x1b[0m"

//defining CONSTANTS
#define NB 32
#define PP (NB/2)+1
#define NLVL 7 

int main (){

  int lvl_s[2*NB];
  int HA[NLVL-1][2*NB] = {{0}}; 
  int FA[NLVL-1][2*NB] = {{0}};
  int max_HA[NLVL-1]={0};
  int max_FA[NLVL-1]={0};
  int tot_HA=0, tot_FA=0;
  int n=NLVL;
  int d[7] = {2, 3, 4, 6, 9, 13, 19};
  int i;

  //initializing most right col to '2'
  lvl_s[2*NB-1] = 2;

  //computing the sum of 1s per col of the up most level
  for(i=2*NB-2;i>=0;i--){
    //for odd indexes >= NB, #1s incremented by 2 w.r.t. right col
    //for even indexes >= NB, #1s decremented by 1 w.r.t. right col 
    if(i>=NB){
      if(i%2 == 0){
        lvl_s[i] = lvl_s[i+1] - 1;
	continue;
      }
      else{
        lvl_s[i] = lvl_s[i+1] + 2;
	continue;
      }
    }

    //for 4 central indexes, #1s always equal to #PP (partial products)
    if((i>=NB-4) && (i<NB)){
      lvl_s[i] = PP;
      continue;
    }

    //for index = NB-5, there is a singularity, #1s decremented by 1 w.r.t.right col
    if(i == NB-5){
      lvl_s[i] = lvl_s[i+1] - 1;
      continue;
    }

    //for odd indexes < NB-5, #1s same as right col
    //for even indexes < NB-5, #1s decremented by 1 w.r.t. right col
    else{
      if(i%2 == 0){
        lvl_s[i] = lvl_s[i+1] - 1;
	continue;
      }
      else{
        lvl_s[i] = lvl_s[i+1];
	continue;
      }
    }
  }


  //computing next levels up to LVL 3
  while(n>1){
    printf(C_CYAN "\nLEVEL: %d, d(%d)= %d\n\n" C_RESET, n, n, d[n-1]);

    //printing the vector
    printf(C_WHITE "RED: " C_RESET);
    for(i=0;i<2*NB;i++){ 
      printf("%3d", lvl_s[i]);
    }  

    for(i=2*NB-1;i>=0;i--){
      while((lvl_s[i])>d[n-2]){
        //if distance is '1' an HA is needed
	if((lvl_s[i]-d[n-2]) == 1){
          //adding one HA
	  HA[n-2][i]++;
	  //removing one DOT due to HA
          lvl_s[i]--;
	  //adding one DOT to next col due to HA
          lvl_s[i-1]++;
          continue;
        }

        //if distance is greater than '1' a FA is needed
	if((lvl_s[i]-d[n-2]) > 1){
	  //adding one FA
          FA[n-2][i]++;
	  //removing two DOTS due to FA
          lvl_s[i] = lvl_s[i] - 2;
	  //adding one DOT to next col due to FA
          lvl_s[i-1]++;
          continue;
        }
      }
    }

    //printing all cols indexes
    printf(C_WHITE "\n\nPOS: " C_RESET);

    for(i=2*NB-1;i>=0;i--){
      printf(C_YELLOW "%3d" C_RESET, i);
    }

    //printing all FAs per col
    printf(C_WHITE "\nFAS: " C_RESET);

    for(i=0;i<2*NB;i++){
      printf("%3d", FA[n-2][i]);
      max_FA[n-2]+=FA[n-2][i];    
    }

    //printing MAX #FAs per level
    printf(C_CYAN "  --> #FA: %d" C_RESET, max_FA[n-2]);

    //printing all HAs per col
    printf(C_WHITE "\nHAS: " C_RESET);

    for(i=0;i<2*NB;i++){
      printf("%3d", HA[n-2][i]);
      max_HA[n-2]+=HA[n-2][i];      
    }

    //printing MAX #HAs per level
    printf(C_CYAN "  --> #HA: %d" C_RESET, max_HA[n-2]);

    // printing a row of separators
    printf("\n");
    for(i=0;i<7*NB;i++){
      printf("-");
    }
    printf("\n");

    //computing TOT #HAs
    tot_HA+=max_HA[n-2];

    //computing TOT #FAs
    tot_FA+=max_FA[n-2];

    //going to next level decrementing 'n'
    n--;
  }

  //printing TOT #FAs
  printf("\n\nTOTAL #FAs: %d\n", tot_FA);

  //printing TOT #HAs
  printf("TOTAL #HAs: %d\n\n", tot_HA);

  return 0;
}
