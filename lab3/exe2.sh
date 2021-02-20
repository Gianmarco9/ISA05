#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

cd sim
echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_abs-test || exit -1
./comp_and_sim.sh -nogui compile_order_abs-pre || exit -1

cd ../py_files
echo -e "\e[1mRUNNING PYTHON SCRIPT TO GENERATE CPU'S STATE TRACES PER CLOCK CYCLE:\n\e[0m"
python3 cpu_analyzer.py ../sim/monitor_abs.txt || exit -1

cd ../syn
#echo -e "\e[1mSTARTING SYNTHESYS OF RISCV_CPU WITH ABS MODULE STRUCTURE WITH MAX FREQUENCY:\n\e[0m"
#./start_syn2.sh 0.0 || exit -1

#clock=$(cat clock.txt)
#clock=$(echo "$clock / 4" | bc -l | sed 's/^\./0\./g')
echo -e "\e[1mSTARTING SYNTHESYS OF RISCV_CPU WITH ABS MODULE STRUCTURE WITH F/4:\n\e[0m"
./start_syn2.sh 14.0 || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-SYNTHESYS SIMULATION OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m" # @ f/4
./comp_and_sim.sh -nogui compile_order_abs-pos || exit -1
echo -e "\e[1mCHECKING MEMORY COMPLIANCE USING GNU's diff:\n\e[0m"
dummy=$(diff ../tb/final_data_ram_dump_abs-pos.txt ../tb/final_data_ram_dump_abs-pre.txt); [ -z "$dummy" ] && echo -e "\e[32mData memory content complies with the pre-synthesis one\e[0m" || echo -e "\e[31mData memory content differs from the pre-synthesis one!\e[0m"

cd ../syn
echo -e "\e[1mCOMPUTING POWER CONSUMPTION OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m"
./pow_anal.sh power_analysis_abs.tcl RISCV_CPU_abs || exit -1

cd ../report
echo -e "\e[1mRENAMING POWER REPORT:\n\e[0m"
mv power.txt RISCV_CPU_abs_power.txt || exit -1

cd ../innovus
echo -e "\e[1mSTARTING PLACE AND ROUTE OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m"
./place_route.sh place_n_route_abs.cmd || exit -1

cd ../sim
echo -e "\e[1mSTARTING POST-PLACE AND ROUTE SIMULATION OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_abs-ppr || exit -1
echo -e "\e[1mCHECKING MEMORY COMPLIANCE USING GNU's diff:\n\e[0m"
dummy=$(diff ../tb/final_data_ram_dump_abs-ppr.txt ../tb/final_data_ram_dump_abs-pre.txt); [ -z "$dummy" ] && echo -e "\e[32mData memory content complies with the pre-synthesis one\e[0m" || echo -e "\e[31mData memory content differs from the pre-synthesis one!\e[0m"

cd ../innovus
echo -e "\e[1mSTARTING POWER CONSUMPTION EVALUATION OF RISCV_CPU WITH ABS MODULE STRUCTURE:\n\e[0m"
./place_route.sh place_n_route_abs2.cmd || exit -1

echo -e "\e[1mEXE2 DONE\n\e[0m"
cd ..
exit 0
