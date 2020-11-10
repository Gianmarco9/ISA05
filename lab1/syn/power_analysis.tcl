read_verilog -netlist ../netlist/fir_4.v
read_saif -input ../saif/fir_4_syn.saif -instance tb_fir/UUT -unit ns -scale 1
create_clock -name MY_CLK CLK
report_power > ./report/power_4.txt
quit
