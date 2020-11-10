#! /bin/bash

if [[ "$#" > 0 ]]; then
	echo "Making the directories clean"
	# clear output directories
	[ -d ./work ] && rm -rf ./work/* || mkdir ./work
	[ -d ../netlist ] && rm -rf ../netlist/* || mkdir ../netlist
	[ -d ./report ] || mkdir ./report

	source /software/scripts/init_synopsys_64.18
	# if the first script exists, start synthesis using it. It can be the one to be used to determine the second script's clock
	if [ -e "$1" ]; then
		echo -e "\e[32mStarting the first synthesys: $1\e[0m"
		dc_shell-xg-t -f "$1" || exit -1
		# if the second script is given, means that the second relies on the first results
		if [[ "$#" > 1 ]]; then
			if [ -e "$2" ]; then
				echo "Cleaning work directory"
				[ -d ./work ] && rm -rf ./work/* || mkdir ./work
				echo -e "\e[32mStarting the second synthesys based on previous result: $2\e[0m"
				dc_shell-xg-t -f "$2" || exit -1
			else
				echo -e "\e[31m[ ERROR ]: Input script2 not found\e[0m"
				exit -1
			fi
		fi
	else
		echo -e "\e[31m[ ERROR ]: Input script1 not found\e[0m"
		exit -1
	fi		
else
	echo -e "\e[31m[ ERROR ]: Input script is needed\e[0m"
	exit -1
fi

exit 0
