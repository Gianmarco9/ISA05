module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
    FPmbe FPmul_under_test(.FP_A(in_inter.A), .FP_B(in_inter.B), .RST_n(!in_inter.rst), .clk(in_inter.clk), .FP_Z(out_inter.data));

	int counter;
	logic [nb-1:0] A,B;

    always_ff @(posedge in_inter.clk)
	
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
	    counter = 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
			
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
			if (counter == 0) begin
				A = in_inter.A;
				B = in_inter.B;
			end
		    end
		    if (counter == pipe_stages) begin
                        //$display("FPmul: input A = %f, input B = %f, output OUT = %f",$bitstoshortreal(in_inter.A),$bitstoshortreal(in_inter.B),$bitstoshortreal(out_inter.data));
                        $display("FPmul: input A = %h, input B = %h, output OUT = %h",A,B,out_inter.data);
                        out_inter.valid <= 1;
                        state <= SEND;
                    end
		    counter++;
                end
                
                SEND: begin
                    if(out_inter.ready) begin
			counter = 0;
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT
