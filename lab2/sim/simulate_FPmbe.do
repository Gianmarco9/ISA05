vsim -t ns -novopt work.tb_FPmbe
wave add *
run 10 us
quit -f
