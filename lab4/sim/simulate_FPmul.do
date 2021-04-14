vsim top
run -all 
#add wave -position insertpoint sim:/top/FPmul/in_inter/clk
#add wave -position insertpoint sim:/top/FPmul/in_inter/rst
#add wave -position insertpoint sim:/top/FPmul/in_inter/A
#add wave -position insertpoint sim:/top/FPmul/in_inter/B
#add wave -position insertpoint sim:/top/FPmul/in_inter/ready
#add wave -position insertpoint sim:/top/FPmul/in_inter/valid
#add wave -position insertpoint sim:/top/FPmul/out_inter/data
#add wave -position insertpoint sim:/top/FPmul/out_inter/ready
#add wave -position insertpoint sim:/top/FPmul/out_inter/valid
#add wave -position insertpoint sim:/top/FPmul/FPmul_under_test/FP_A
#add wave -position insertpoint sim:/top/FPmul/FPmul_under_test/FP_B
#add wave -position insertpoint sim:/top/FPmul/FPmul_under_test/FP_Z
#add wave -position insertpoint  \
#sim:/top/state
quit -f
