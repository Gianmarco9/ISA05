vsim -t ns -novopt work.tb_RISCV_CPU
wave add *
run 1610 ns
quit -f
