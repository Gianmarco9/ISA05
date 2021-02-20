#! /bin/bash

if [[ "$#" > 0 ]]; then
	if [ -e "$1" ]; then
		source /software/scripts/init_innovus17.11
		innovus -batch -files "$1" -no_gui || exit -1
	else
		echo "\e[31m[ ERROR ]: The command file does not exist!\e[0m"
		exit -1
	fi
fi

exit 0
