vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_fir
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_fir/UUT=../innovus/fir_4.sdf work.tb_fir
vcd file ../vcd/fir_4_design.vcd
vcd add /tb_fir/UUT/*
run 3 us
quit -f
