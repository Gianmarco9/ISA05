source .synopsys_dc.setup
source analyze_order_adv.do
set power_preserve_rtl_hier_names true
elaborate fir_adv -arch structural -lib WORK > ./elaborate_adv.txt
uniquify
link

source synth_clk.tcl

puts "Computing worst negative slack -> CLK_PERIOD = 0.0"
set slack [synth_clk 0.0]
puts "Obtained slack: $slack"
set value_clk [expr {-1*$slack}]
puts "Minimum CLK_PERIOD = $value_clk"
synth_clk $value_clk

set fid [open "min_clk_period.txt" w]
puts $fid "$value_clk"
close $fid

report_timing > ./report/timing_adv.txt
report_area > ./report/area_adv.txt

ungroup -all -flatten

change_names -hierarchy -rules verilog

write_sdf ../netlist/fir_adv.sdf

write -f verilog -hierarchy -output ../netlist/fir_adv.v

write_sdc ../netlist/fir_adv.sdc

quit
