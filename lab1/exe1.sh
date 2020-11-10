#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

cd sim
echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF BASIC FIR STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_pre || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_pre.txt); [ -z "$dummy" ] && echo -e "\e[32mVHDL implementation complies with the C one\e[0m" || echo -e "\e[31mVHDL implementation differs from the C one!\e[0m"


cd ../syn
echo -e "\e[1mSTARTING SYNTHESYS OF BASIC FIR STRUCTURE:\n\e[0m"
./start_syn.sh synth.tcl synth_f_4.tcl || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-SYNTHESYS SIMULATION OF BASIC FIR STRUCTURE:\n\e[0m" # @ f/4
./comp_and_sim.sh -nogui compile_order_pos || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_pos.txt); [ -z "$dummy" ] && echo -e "\e[32mVerilog backannotation result complies with the C one\e[0m" || echo -e "\e[31mVerilog backannotation result differs from the C one!\e[0m"

cd ../syn
echo -e "\e[1mCOMPUTING POWER CONSUMPTION OF BASIC FIR STRUCTURE:\n\e[0m"
./pow_anal.sh power_analysis.tcl fir_4 || exit -1

cd ../innovus
echo -e "\e[1mSTARTING PLACE AND ROUTE OF BASIC FIR STRUCTURE:\n\e[0m"
./place_route.sh place_n_route.cmd || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-PLACE AND ROUTE SIMULATION OF BASIC FIR STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_ppr || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_ppr.txt); [ -z "$dummy" ] && echo -e "\e[32mVerilog backannotation result complies with the C one\e[0m" || echo -e "\e[31mVerilog backannotation result differs from the C one!\e[0m"

cd ../innovus
echo -e "\e[1mSTARTING POWER CONSUMPTION EVALUATION OF BASIC FIR STRUCTURE:\n\e[0m"
./place_route.sh place_n_route2.cmd || exit -1

echo -e "\e[1mEXE1 DONE\n\e[0m"
cd ..
exit 0
