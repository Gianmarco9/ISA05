vsim -t ns -novopt work.tb_RISCV_CPU_abs
add wave *
run 1316 ns
quit -f
