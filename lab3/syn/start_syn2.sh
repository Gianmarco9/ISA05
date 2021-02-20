#! /bin/bash

trap '(( "$?" == 0 )) || echo -e "\e[31m[ ERROR ]: an error occurred in $0\e[0m"' EXIT

if [[ "$#" != 1 ]]; then 
	echo -e "\e[31m[ ERROR ]: wrong number of arguments\e[0m" 
	exit -1 
else 
	echo "Making the directories clean"
	# clear output directories
	[ -d ./work ] && rm -rf ./work/* || mkdir ./work
	[ -d ../netlist ] || mkdir ../netlist
	[ -d ../report ] || mkdir ../report
	source /software/scripts/init_synopsys_64.18

	echo -e "\e[1;32mSYNTHESIZING CPU WITH ABS MODULE...\e[0m"
	#initialize slack and clock
	slack="-1"
	echo "$1" > clock.txt
	#basic loop synthesis
	while (( $(echo "$slack < 0" |bc -l) ))
	do
	clock=$(cat "clock.txt")
	dc_shell-xg-t -f syn_abs_basic.tcl || exit -1
	slack=$(cat "slack.txt")
	if (( $(echo "$slack < 0" |bc -l) )); then
		clock="$(echo "$clock - $slack" |bc -l)"
		echo "Making the work directory clean"
		rm -rf ./work/*
	fi
	echo "$clock" > clock.txt
	done

	echo "SYNTH DONE!"
fi
exit 0
