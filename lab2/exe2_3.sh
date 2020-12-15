#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

#ADD_REG = 2 DUE TO ADDITIONAL REGISTERS BETWEEN STAGE 2 AND STAGE 3
echo -e "\e[1mMODIFYING CONSTANT \"ADD_REG\" TO 2 IN MYPACKAGE.VHD...\n\e[0m"
awk -v addregs=2 '{if ($2 == "add_reg") {gsub(/[0-9]+/, addregs)} {print}}' < ./src/common/mypackage.vhd > tmp; mv tmp ./src/common/mypackage.vhd

cd py_files
echo -e "\e[1mRUNNING PYTHON SCRIPT TO GENERATE THE COLLAPSED MATRIX OF SIGNALS FEEDING DADDA TREE...\n\e[0m"
python3 matrix_filler.py 32 || exit -1
echo -e "\e[1mRUNNING PYTHON SCRIPT TO GENERATE THE VHDL CODE OF THE DADDA TREE...\n\e[0m"
python3 dadda_tree.py 32 4 || exit -1
echo -e "\e[1mRUNNING PYTHON SCRIPT TO GENERATE INPUT DATA FOR TESTING MBE...\n\e[0m"
python3 random_gen.py 32 100 || exit -1


cd ../sim
echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF MBE STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_mbe || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff --ignore-case results_py.hex results_mbe.hex); [ -z "$dummy" ] && echo -e "\e[32mVHDL implementation complies with Python's results\e[0m" || echo -e "\e[31mVHDL implementation differs from Python's results!\e[0m"

echo -e "\e[1mSTARTING COMPILATION AND SIMULATION OF OPTIMIZED FPMBE STRUCTURE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_FPmbe || exit -1
echo -e "\e[1mCHECKING RESULT USING GNU's diff:\n\e[0m"
dummy=$(diff --ignore-case fp_prod.hex results_FPmbe.hex); [ -z "$dummy" ] && echo -e "\e[32mVHDL implementation complies with Calculator's results\e[0m" || echo -e "\e[31mVHDL implementation differs from Calculator's results!\e[0m"


cd ../syn
echo -e "\e[1mSTARTING SYNTHESYS OF OPTIMIZED FPMBE STRUCTURE:\n\e[0m"
./start_syn3.sh 0.0 0.0 || exit -1

echo -e "\e[1mEXE2_3 DONE!\n\e[0m"
cd ..
exit 0
