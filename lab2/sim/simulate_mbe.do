vsim -t ns -novopt work.tb_MBE
wave add *
run 10 us
quit -f
