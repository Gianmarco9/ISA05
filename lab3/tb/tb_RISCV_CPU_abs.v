//`timescale 1ns
 
module tb_RISCV_CPU_abs ();

   parameter nb=32;
   parameter INSTR_WIDTH=32;
   parameter MEM_ADDR_SIZE=12;
   wire CLK_i;
   wire RST_n_i;
    wire [nb-1:0] PC_i;
    wire [INSTR_WIDTH-1:0] INSTR_i;
    wire MEM_READ_i;
    wire MEM_WRITE_i;
    wire DUMP_i;
    wire [nb-1:0] ADDR_MEM_i;
    wire [nb-1:0] WR_DATA_i;
    wire [nb-1:0] RD_DATA_i;

   clk_RISCV_abs CG(.CLK(CLK_i),
	.RST_n(RST_n_i),
	.DUMP(DUMP_i));

   IRAM #(.file_path("../tb/instruction_ram_dump_abs.txt"))
   IR(
	.CLK(CLK_i),
	.RST_n(RST_n_i),
	.ADDRESS(PC_i[MEM_ADDR_SIZE-1:0]),
	.DOUT(INSTR_i));

   DRAM #(.dump_path("../tb/final_data_ram_dump_abs.txt")) 
   DR(
	.CLK(CLK_i),
	.RST_n(RST_n_i),
	.RD(MEM_READ_i),
	.WR(MEM_WRITE_i),
	.DUMP(DUMP_i),
	.ADDRESS(ADDR_MEM_i[MEM_ADDR_SIZE-1:0]),
	.DATAIN(WR_DATA_i),
	.DATAOUT(RD_DATA_i));

   RISCV_CPU_abs DUT(
	.CLK(CLK_i),
	.RST_n(RST_n_i),
	.INSTR(INSTR_i),
	.READ_DATA(RD_DATA_i),
	.PC(PC_i),
	.ADDR_MEM(ADDR_MEM_i),
	.WRITE_DATA(WR_DATA_i),
	.MEM_WRITE(MEM_WRITE_i),
	.MEM_READ(MEM_READ_i));
endmodule
