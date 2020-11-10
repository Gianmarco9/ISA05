vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_fir_adv
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_fir_adv/UUT=../netlist/fir_adv_4.sdf work.tb_fir_adv
vcd file ../vcd/fir_adv_4_syn.vcd
vcd add /tb_fir_adv/UUT/*
run 3 us
quit -f
