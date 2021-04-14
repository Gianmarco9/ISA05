`include "../tb/adder/my_defines.svh" 

interface dut_if(input clk, rst);
    
    logic [nb-1:0] A, B;
    logic [nb-1:0] data;
    logic valid, ready;
    
    modport port_in (input clk, rst, A, B, valid, output ready);
    modport port_out (input clk, rst, output valid, data, ready);
endinterface
