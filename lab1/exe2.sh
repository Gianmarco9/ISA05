#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

cd sim
echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF ADVANCED FIR STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_adv-pre || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_adv-pre.txt); [ -z "$dummy" ] && echo -e "\e[32mVHDL implementation complies with the C one\e[0m" || echo -e "\e[31mVHDL implementation differs from the C one!\e[0m"


cd ../syn
echo -e "\e[1mSTARTING SYNTHESYS OF ADVANCED FIR STRUCTURE:\n\e[0m"
./start_syn.sh synth_adv.tcl synth_adv_4.tcl || exit -1
#./start_syn.sh synth_adv_4.tcl || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-SYNTHESYS SIMULATION OF ADVANCED FIR STRUCTURE:\n\e[0m" # @ f/4
./comp_and_sim.sh -nogui compile_order_adv-pos || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_adv-pos.txt); [ -z "$dummy" ] && echo -e "\e[32mVerilog backannotation result complies with the C one\e[0m" || echo -e "\e[31mVerilog backannotation result differs from the C one!\e[0m"

cd ../syn
echo -e "\e[1mCOMPUTING POWER CONSUMPTION OF ADVANCED FIR STRUCTURE:\n\e[0m"
./pow_anal.sh power_analysis_adv.tcl fir_adv_4 || exit -1

cd ../innovus
echo -e "\e[1mSTARTING PLACE AND ROUTE OF ADVANCED FIR STRUCTURE:\n\e[0m"
./place_route.sh place_n_route_adv.cmd || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-PLACE AND ROUTE SIMULATION OF ADVANCED FIR STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_adv-ppr || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff resultsC.txt results_adv-ppr.txt); [ -z "$dummy" ] && echo -e "\e[32mVerilog backannotation result complies with the C one\e[0m" || echo -e "\e[31mVerilog backannotation result differs from the C one!\e[0m"

cd ../innovus
echo -e "\e[1mSTARTING POWER CONSUMPTION EVALUATION OF ADVANCED FIR STRUCTURE:\n\e[0m"
./place_route.sh place_n_route_adv2.cmd || exit -1

echo -e "\e[1mEXE2 DONE\n\e[0m"
cd ..
exit 0
