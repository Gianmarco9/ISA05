//`timescale 1ns
 
module tb_MBE ();

   parameter nb=32;

   wire CLK_i;
   wire RST_n_i;
   wire [nb-1:0] A_i,B_i;	
   wire [2*nb-1:0] P_i;
   wire END_SIM_i;

   clk_gen CG(
	      .END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i)
	     );

   data_maker_mbe DM(
        	     .CLK(CLK_i),
	     	     .RST_n(RST_n_i),
		     .DATA_A(A_i),
		     .DATA_B(B_i),
		     .END_SIM(END_SIM_i)
		    );

   MBE UUT(	
	    .A(A_i),
	    .B(B_i),
	    .DOUT(P_i)
	   );

   data_sink_mbe DS(
        	    .CLK(CLK_i),
		    .RST_n(RST_n_i),
		    .DATA(P_i)
		   );

endmodule
