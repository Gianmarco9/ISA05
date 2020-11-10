//`timescale 1ns

module tb_fir_adv ();

   parameter nb=11, order=10, tot_bit=(order+1)*nb;

   wire CLK_i;
   wire RST_n_i;
   wire [nb-1:0] DIN1_i;
   wire [nb-1:0] DIN2_i;
   wire [nb-1:0] DIN3_i;
   wire VIN_i;
   wire [tot_bit-1:0] H_i;
   wire [nb-1:0] DOUT1_i;
   wire [nb-1:0] DOUT2_i;
   wire [nb-1:0] DOUT3_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker_adv DM(.CLK(CLK_i),
	             .RST_n(RST_n_i),
		     .VOUT(VIN_i),
		     .DOUT1(DIN1_i),
                     .DOUT2(DIN2_i),
                     .DOUT3(DIN3_i),
		     .H(H_i),
		     .END_SIM(END_SIM_i));

   fir_adv UUT(.CLK(CLK_i),
	       .RST_n(RST_n_i),
	       .DIN1(DIN1_i),
               .DIN2(DIN2_i),
               .DIN3(DIN3_i),
               .VIN(VIN_i),
	       .b(H_i),
               .DOUT1(DOUT1_i),
               .DOUT2(DOUT2_i),
               .DOUT3(DOUT3_i),
               .VOUT(VOUT_i));

   data_sink_adv DS(.CLK(CLK_i),
		    .RST_n(RST_n_i),
	 	    .VIN(VOUT_i),
                    .DIN1(DOUT1_i),
                    .DIN2(DOUT2_i),
		    .DIN3(DOUT3_i));

endmodule
