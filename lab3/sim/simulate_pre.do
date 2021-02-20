vsim -t ns -novopt work.tb_RISCV_CPU
add wave *
run 1610 ns
quit -f
