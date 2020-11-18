SCRIPT MANUAL:

NOTE:	"adv" string is related to the Unfolded + Pipelined architecture.
	"4" string is related to the synthesis using a clock frequency 4 times slower than the 
	maximum allowed.
	"pre" string is related to the simulation of the architecture before synthesis.
	"pos" string is related to the simulation of the architecture after synthesis.
	"ppr" string is related to the simulation of the architecture after place and route.


################################################################################################
BASH_SCRIPTS:
exe1.sh
	GOAL: Run all the scripts to simulate, synthesize, place and route and power analyze 
		the architecture descripted in the sourced files, following the specified 
		design flow. Also checks the results after simulations.
	SYNTAX: exe1.sh [no_args]
		
		
comp_and_sim.sh
	GOAL: Compile the source file (vhdls and verilogs) in the order specified into the 
		compile_order_* files. Then simulate the architecture using the commands listed into
		the simulate_*.do files. The files references are resolved thanks to an intelligent
		postfix management, so the results and simulate_*.do have the respective postfix.
		The [launch_opt] is required since it specifies the mode used to launch Modelsim.
		[launch_opt] must be "-nogui" or "-dbg". The first launches Modelsim without gui, 
		the second with a gui.
		It is called 3 times: the initial simulation, the post synthesis and then after 
		place and route simulation.
	SYNTAX: comp_and_sim.sh [launch_opt] <compile_order*>
	NOTE: DESCRIBE THE MODELSIM SCRIPT

start_syn.sh
	GOAL: Synthesize the architecture using the sourced script files. The second script is
		useful in case the maximum clock frequecy is found by the first script and the
		second use this information to synthesize the architecture. It can also directly
		synthesize a single architecture, sourcing only one script.
	SYNTAX: start_syn.sh <first_script> <second_script>
	
	
pow_anal.sh
	GOAL: Evaluate the power consumption, based on the result of the switching activity
		of the design simulated by Modelsim, using Synopsys. The entity name is used
		to target the correct vcd file.
	SYNTAX: pow_anal.sh <power_analysis_*.tcl> <entity_name>
	
	
place_route.sh
	GOAL: Calls Innovus in batch mode giving a tcl script.
		It is called two times, the first realizes the physical placement (sourcing the files 
		described into design.globals* mmm_design.tcl), the second involves the capacitance 
		extraction power consumption computation, based on the switching activity computed by 
		Modelsim place and route.
	SYNTAX: place_route.sh <place_n_route*.tcl>
	


################################################################################################
MODELSIM_SCRIPTS:
simulate_*.do:
	GOAL: Simulate the given architecture using the stimuli and commands specified into this
		file, which contains Modelsim directives. In short, starts, computes and ends the 
		simulation.
		The postfix "pre" is related to the first simulation of the architecture.
		The "pos" one is related to the simulation ater synthesis (also calculates switching
		activity) using the automatic verilog description produced by Synopsys.
		The "ppr" one is related to the simulation after place and route using the verilog
		source file produced by Innovus.
		
		
		
################################################################################################
SYNOPSYS_SCRIPTS:
synth_clk.tcl:
	GOAL: This procedure creates a clock with the specified characteristics, sets the output
		load, compiles the architecture and extracts the slack and critical path. The slack 
		is used to determine the minimum clock period for the first script executed which calls
		it. The second time this procedure is called, is simply used for creating the new clock,
		assign the output load and compile command.
	SYNTAX: synth_clk.tcl <clock_value>
		
synth*.tcl:
	GOAL: This script analyzes first the vhd files specified into the respective analyze_order*.do
		files, then elaborates the top entity and finally calls synth_clk.tcl giving a Null 
		period clock to find the minimum period as the slack by synth_clk.tcl. This slack is 
		saved into min_clk_period.txt file. Furthermore save the area and timing reports,
		writes the sdf, verilog backannotation and sdc file.
		
synth*_4.tcl: 
	GOAL: This script analyzes first the vhd files specified into the respective analyze_order*.do
		files, then elaborates the top entity and finally calls synth_clk.tcl giving as clock
		period 4 times the one written into min_clk_period.txt. Furthermore save the area and 
		timing reports, writes the sdf, verilog backannotation and sdc file.
		
power_analysis*.tcl: 
	GOAL: This script reads the verilog and saif file, then reports the related power.
	
analyze_order*.do:
	GOAL: analyzes the vhd files in the specified order.
	
	
	
################################################################################################
INNOVUS_SCRIPTS:
place_n_route*.cmd:
	GOAL: Replicates the design flow done using the GUI until power evaluation, but in batch mode.
	
place_n_route*2.cmd:
	GOAL: Restore the design generated by place_n_route*.cmd and then evaluate the power consumption, 
		based on the result of the switching activity of the design after place and route simulated 
		by Modelsim, using Innovus.
	
	
################################################################################################
C_FILE:
Makefile:
	GOAL: Compile a Software model of the filter with different number of bits truncated.
		The executable file produces the output file used to check the correctness of
		the design.
		"fir" target is the simplest filter version with no particular features.
		"fir_trunc" is the filter whose internal architecture drops the last specified 
		bits.
		"fir_adder_analyze" is the filter in which the internal node values are visible
		on standard output.
		"fir_analyze" is the combination of "fir_trunc" and "fir_adder_analyze" features.
		
myfilter_mod.c:
	GOAL: The source code to be compiled, in which the filter is modeled. The different 
		features/behaviours are selected through conditional compilation.



