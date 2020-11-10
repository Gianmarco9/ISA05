vsim -t ns -novopt work.tb_fir
wave add *
run 3 us
quit -f
