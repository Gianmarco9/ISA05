#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

#ADD_REG = 1 DUE TO INPUT REGISTERS
echo -e "\e[1mMODIFYING CONSTANT \"ADD_REG\" TO 1 IN MYPACKAGE.VHD...\n\e[0m"
awk -v addregs=1 '{if ($2 == "add_reg") {gsub(/[0-9]+/, addregs)} {print}}' < ./src/common/mypackage.vhd > tmp; mv tmp ./src/common/mypackage.vhd

cd sim
echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF BASIC FPMUL STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_first || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff --ignore-case fp_prod.hex results_first.hex); [ -z "$dummy" ] && echo -e "\e[32mVHDL implementation complies with Calculator's results\e[0m" || echo -e "\e[31mVHDL implementation differs from Calculator's results!\e[0m"


cd ../syn
echo -e "\e[1mSTARTING SYNTHESYS OF BASIC FPMUL STRUCTURE:\n\e[0m"
./start_syn1.sh 0.0 0.0 0.0 || exit -1

echo -e "\e[1mEXE2_1 DONE!\n\e[0m"
cd ..
exit 0
