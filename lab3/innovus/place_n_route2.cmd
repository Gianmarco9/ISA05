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
restoreDesign /home/isa05/labs/lab3/innovus/RISCV_CPU.enc.dat RISCV_CPU

reset_parasitics
extractRC
rcOut -setload RISCV_CPU.setload -rc_corner my_rc
rcOut -setres RISCV_CPU.setres -rc_corner my_rc
rcOut -spf RISCV_CPU.spf -rc_corner my_rc
rcOut -spef RISCV_CPU.spef -rc_corner my_rc
set_power_analysis_mode -reset
set_power_analysis_mode -method static -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 10.0
read_activity_file -reset

read_activity_file -format VCD -scope tb_RISCV_CPU/DUT -start {} -end {} -block {} ../vcd/RISCV_CPU_design.vcd
set_power -reset
set_powerup_analysis -reset
set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile ../report/RISCV_CPU_sw_act_power_rail_ppr.rpt
report_power -outfile ../report/RISCV_CPU_after_sw_act_power.rpt -sort { total }
dumpToGIF RISCV_CPU.gif
