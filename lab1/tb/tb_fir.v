//`timescale 1ns
 
module tb_fir ();

   parameter nb=11, order=10, tot_bit=(order+1)*nb;

   wire CLK_i;
   wire RST_n_i;
   wire [nb-1:0] DIN_i;
   wire VIN_i;	
   wire [tot_bit-1:0] H_i;		
   wire [nb-1:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker DM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .H(H_i),
		 .END_SIM(END_SIM_i));

   fir UUT(.CLK(CLK_i),
	   .RST_n(RST_n_i),
	   .DIN(DIN_i),
           .VIN(VIN_i),
	   .b(H_i),	   
           .DOUT(DOUT_i),
           .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));

endmodule
