proc select_compilation {option arch_mul} {

        if {$option == "basic"} {
                compile
        }

        if {$option == "set_arch"} {
                set_implementation DW02_mult/$arch_mul [find cell *mult*]
                compile
        }

        if {$option == "retiming"} {
                compile
                optimize_registers
        }

        if {$option == "ultra"} {
                compile_ultra
        }

        return 0

}

proc synth {entity architecture analyze option arch_mul} {
	source .synopsys_dc.setup

	if {$analyze == "null"} {
		source analyze_order.do
	} else {
		source analyze_order_$analyze.do
	}

	set power_preserve_rtl_hier_names true
	
	if {$arch_mul == "null"} {
		set postfix $option
	} else {
		set postfix $option\_$arch_mul
	}
	
	elaborate $entity -arch $architecture -lib WORK > ./elaborate\_$entity\_$postfix.txt
	uniquify
	link
	
	#read new clk for architecture
	set fid [open "clock.txt" r]
	gets $fid line
	set value_clk $line
	close $fid
	
	#new_clock
	puts "########## CREATING A NEW CLOCK = $value_clk ##########"
	create_clock -name MY_CLK -period $value_clk CLK
        set_dont_touch_network MY_CLK
        set_clock_uncertainty 0.07 [get_clocks MY_CLK]
        set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
        set_output_delay 0.5 -max -clock MY_CLK [all_outputs]

	#capacitance
        set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
        set_load $OLOAD [all_outputs]

	#remove hierarchy
        ungroup -all -flatten

	#to choose type of compilation
	select_compilation $option $arch_mul

	#new slack
	set slack [get_attribute [get_timing_path] slack]
	puts "########## OBTAINED SLACK: $slack ##########"

	#write on a file new slack 
	set fid [open "slack.txt" w]
	puts $fid $slack
	close $fid

	if {$slack >= 0} {	
		#all reports
		report_resources > ../report/$entity\_resources.txt
		report_timing > ../report/$entity\_timing.txt
		report_area > ../report/$entity\_area.txt

		#Printing netlist in verilog	
		change_names -hierarchy -rules verilog

		#netlist files
		write_sdf ../netlist/$entity.sdf
		write -f verilog -hierarchy -output ../netlist/$entity.v
		write_sdc ../netlist/$entity.sdc
	}
	return 0
}



