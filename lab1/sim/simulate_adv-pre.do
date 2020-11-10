vsim -t ns -novopt work.tb_fir_adv
wave add *
run 3 us
quit -f
