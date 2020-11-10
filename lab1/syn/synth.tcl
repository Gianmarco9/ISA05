source .synopsys_dc.setup
source analyze_order.do
set power_preserve_rtl_hier_names true
elaborate fir -arch structural -lib WORK > ./elaborate.txt
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

report_timing > ./report/timing.txt
report_area > ./report/area.txt

ungroup -all -flatten

change_names -hierarchy -rules verilog

write_sdf ../netlist/fir.sdf

write -f verilog -hierarchy -output ../netlist/fir.v

write_sdc ../netlist/fir.sdc

quit
