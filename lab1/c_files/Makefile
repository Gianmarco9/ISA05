CC=gcc
CFLAGS=-Wall -Wextra

help:
	echo "-> Simple compilation with base internal product bit truncation:"
	echo -e "\tmake fir.out\n"
	echo "-> Compile with specified truncation:"
	echo -e "\tmake fir_trunc bit_loss=N"

fir: myfilter_mod.c
	$(CC) $(CFLAGS) myfilter_mod.c -o fir.out
	
fir_trunc: myfilter_mod.c
	$(CC) -DBIT_LOSS=$(bit_loss) $(CFLAGS) myfilter_mod.c -o fir.out
	
fir_adder_analyze: myfilter_mod.c
	$(CC) -DADDER_ANALYZE $(CFLAGS) myfilter_mod.c -o fir.out
	
fir_analyze: myfilter_mod.c
	$(CC) -DADDER_ANALYZE -DBIT_LOSS=$(bit_loss) $(CFLAGS) myfilter_mod.c -o fir.out
