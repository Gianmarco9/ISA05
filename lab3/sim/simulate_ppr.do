vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_RISCV_CPU
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_RISCV_CPU/DUT=../innovus/RISCV_CPU.sdf work.tb_RISCV_CPU
vcd file ../vcd/RISCV_CPU_design.vcd
vcd add /tb_RISCV_CPU/DUT/*
run 1610 ns
quit -f
