source .synopsys_dc.setup
source analyze_order_adv.do
set power_preserve_rtl_hier_names true
elaborate fir_adv -arch structural -lib WORK > ./elaborate_adv.txt
uniquify
link

source synth_clk.tcl

set fid [open "min_clk_period.txt" r]

while {[gets $fid line] >= 0} {
	set value_clk $line
}
close $fid

set value_clk [expr {4*$value_clk}]

puts "Synthesizing with CLK_PERIOD = $value_clk"
synth_clk $value_clk

report_timing > ./report/timing_adv_4.txt
report_area > ./report/area_adv_4.txt

ungroup -all -flatten

change_names -hierarchy -rules verilog

write_sdf ../netlist/fir_adv_4.sdf

write -f verilog -hierarchy -output ../netlist/fir_adv_4.v

write_sdc ../netlist/fir_adv_4.sdc

quit
