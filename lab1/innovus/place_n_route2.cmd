#reload the design
set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
# do we have to re-source design.globals and mmm_design.tcl ?
#source design.globals
#set init_mmmc_file mmm_design.tcl
encMessage warning 0
encMessage debug 0
encMessage info 0
restoreDesign /home/isa05/labs/lab1/innovus/fir_4.enc.dat fir

reset_parasitics
extractRC
rcOut -setload fir.setload -rc_corner my_rc
rcOut -setres fir.setres -rc_corner my_rc
rcOut -spf fir.spf -rc_corner my_rc
rcOut -spef fir.spef -rc_corner my_rc
set_power_analysis_mode -reset
set_power_analysis_mode -method static -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset

read_activity_file -format VCD -scope tb_fir/UUT -start {} -end {} -block {} ../vcd/fir_4_design.vcd
set_power -reset
set_powerup_analysis -reset
set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile ./fir_4_sw_act_power_rail_ppr.rpt
report_power -outfile after_sw_act_power.rpt -sort { total }
#dumpToGIF fir_4.gif
