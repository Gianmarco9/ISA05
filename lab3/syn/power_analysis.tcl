read_verilog -netlist ../netlist/RISCV_CPU.v
current_design RISCV_CPU
read_saif -input ../saif/RISCV_CPU_syn.saif -instance tb_RISCV_CPU/DUT -unit ns -scale 1
create_clock -name MY_CLK CLK
report_power > ../report/power.txt
quit
