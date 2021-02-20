vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_RISCV_CPU_abs
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_RISCV_CPU_abs/DUT=../innovus/RISCV_CPU_abs.sdf work.tb_RISCV_CPU_abs
vcd file ../vcd/RISCV_CPU_abs_design.vcd
vcd add /tb_RISCV_CPU_abs/DUT/*
run 1316 ns
quit -f
