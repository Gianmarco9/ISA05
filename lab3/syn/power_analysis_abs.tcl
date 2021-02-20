read_verilog -netlist ../netlist/RISCV_CPU_abs.v
current_design RISCV_CPU_abs
read_saif -input ../saif/RISCV_CPU_abs_syn.saif -instance tb_RISCV_CPU_abs/DUT -unit ns -scale 1
create_clock -name MY_CLK CLK
report_power > ../report/power.txt
quit
