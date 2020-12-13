//`timescale 1ns
 
module tb_FPmbe ();

   parameter nb=32;

   wire CLK_i;
   wire RST_n_i;
   wire [nb-1:0] FP_A_i,FP_Z_i;	
   wire END_SIM_i;

   clk_gen CG(
	      .END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i)
	     );

   data_maker DM(
         	 .CLK(CLK_i),
	     	 .RST_n(RST_n_i),
		 .DATA(FP_A_i),
		 .END_SIM(END_SIM_i)
		);

   FPmbe UUT(
	     .FP_A(FP_A_i),
	     .FP_B(FP_A_i),
	     .RST_n(RST_n_i),
	     .clk(CLK_i),
	     .FP_Z(FP_Z_i)
	    );

   data_sink DS(
        	.CLK(CLK_i),
		.RST_n(RST_n_i),
		.DATA(FP_Z_i)
	       );

endmodule
