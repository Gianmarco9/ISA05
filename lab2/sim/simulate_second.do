vsim -t ns -novopt work.tb_FPmul
wave add *
run 10 us
quit -f
