#! /env/python

import random
import sys

if len(sys.argv) != 3:
	print("[ERROR]: wrong number of arguments")
	sys.exit(-1)

n_bit = int(sys.argv[1])
iterations = int(sys.argv[2])
#n_bit = int(input("Data parallelism:\t"))
#iterations = int(input("How many iterations?:\t"))
with open("../tb/inputs_mbe.hex","w") as fileout1,open("../sim/results_py.hex","w") as fileout2:
	for i in range(iterations):
		num_A = random.randint(0,2**n_bit-1)
		num_B = random.randint(0,2**n_bit-1)
		if i == 0:
			num_A = 0
		if i == iterations-1:
			num_A = 2**n_bit-1
			num_B = 2**n_bit-1
		prod = num_A*num_B
		fileout1.write(format(num_A,"0{}x".format(n_bit//4))+"\n")
		fileout1.write(format(num_B,"0{}x".format(n_bit//4))+"\n")
		fileout2.write(format(prod,"0{}x".format(2*n_bit//4))+"\n")


