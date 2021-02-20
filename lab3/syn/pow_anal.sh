#! /bin/bash

if [[ "$#" > 1 ]]; then
	if [ -e "$1" ]; then
		source /software/scripts/init_synopsys_64.18
		echo -e "\e[32mComputing power based on switching activity...\e[0m"
		vcd2saif -input "../vcd/$2_syn.vcd" -output "../saif/$2_syn.saif"
		dc_shell-xg-t -f "$1" || exit -1
	fi
fi

exit 0
