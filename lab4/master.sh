#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: Error occurred!\e[0m"' EXIT

cd sim
echo -e "\e[1mUVM COMPILATION AND SIMULATION OF ADDER:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_adder -qs || exit -1

echo -e "\e[1mUVM COMPILATION AND SIMULATION OF MBE:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_MBE -qs || exit -1

echo -e "\e[1mUVM COMPILATION AND SIMULATION OF FPMUL:\n\e[0m"
./comp_and_sim.sh -nogui compile_order_FPmul -qs || exit -1

echo -e "\e[1mLAB4 DONE\n\e[0m"
cd ..
exit 0
