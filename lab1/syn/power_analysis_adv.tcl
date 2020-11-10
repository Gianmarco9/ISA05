read_verilog -netlist ../netlist/fir_adv_4.v
read_saif -input ../saif/fir_adv_4_syn.saif -instance tb_fir_adv/UUT -unit ns -scale 1
create_clock -name MY_CLK CLK
report_power > ./report/power_adv_4.txt
quit
