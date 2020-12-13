#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: an error occurred in $0\e[0m"' EXIT

if [[ "$#" != 2 ]]; then 
	echo -e "\e[31m[ ERROR ]: wrong number of arguments\e[0m" 
	exit -1 
else 
	echo "Making the directories clean"
	# clear output directories
	[ -d ./work ] && rm -rf ./work/* || mkdir ./work
	[ -d ../netlist ] || mkdir ../netlist
	[ -d ../report ] || mkdir ../report
	source /software/scripts/init_synopsys_64.18

	echo -e "\e[1;32mSYNTHESIZING FPMBE WITH RETIMING...\e[0m"
	#initialize slack and clock
	slack="-1"
	echo "$1" > clock.txt
	#retiming loop synthesis
	while (( $(echo "$slack < 0" |bc -l) ))
	do
	clock=$(cat "clock.txt")
	dc_shell-xg-t -f syn_FPmbe_retiming.tcl || exit -1
	echo "Making the work directory clean"
	rm -rf ./work/*
	slack=$(cat "slack.txt")
	clock="$(echo "$clock - $slack" |bc -l)"
	echo "$clock" > clock.txt
	done

	echo -e "\e[1;32mSYNTHESIZING FPMBE WITH COMPILE ULTRA...\e[0m"
	#initialize slack and clock
	slack="-1"
	echo "$2" > clock.txt
	#ultra loop synthesis
	while (( $(echo "$slack < 0" |bc -l) ))	
	do
	clock=$(cat "clock.txt")
	dc_shell-xg-t -f syn_FPmbe_ultra.tcl || exit -1
	echo "Making the work directory clean"
	rm -rf ./work/*
	slack=$(cat "slack.txt")
	clock="$(echo "$clock - $slack" |bc -l)"
	echo "$clock" > clock.txt
	done

	echo "SYNTH DONE!"
fi
exit 0
