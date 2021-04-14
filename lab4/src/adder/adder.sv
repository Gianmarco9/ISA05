`include "../tb/adder/my_defines.svh"

module adder
		(input logic [nb-1:0] A, B, 
                output logic [nb-1:0] OUT );

    assign OUT = A + B;

endmodule: adder
