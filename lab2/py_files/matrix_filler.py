#! /env/python

import json
import sys

l = []
tmp = 0
sig = "PP_IN({})({})"
total = []

#n_bit = int(input("Data parallelism:\t"))

if len(sys.argv) != 2:
	print("[ERROR]: wrong number of arguments")	
	sys.exit(-1)

n_bit = int(sys.argv[1])
for i in range(2*n_bit):
	if i < n_bit:
		if i % 2 == 0:
			tmp = tmp + 1
			for j in range(tmp+1):
				l = l + [sig.format(j,i)]
			else:
				total = total + [l]
				l = []
		else:
			for j in range(tmp):
				l = l + [sig.format(j,i)]
			else:
				total = total + [l]
				l = []
	elif i >= n_bit and i < n_bit + 4:
		if i == n_bit:
			tmp = tmp + 1
		for j in range(tmp):
			l = l + [sig.format(j,i)]
		else:
			total = total + [l]
			l = []
	elif i == n_bit + 4:
		tmp = tmp - 1
		for j in range(tmp):
			l = l + [sig.format(j,i)]
		else:
			total = total + [l]
			l = []   
	else:
		if i % 2 == 1:
			tmp = tmp - 1
			for j in range(tmp):
				l = l + [sig.format(j,i)]
			else:
				total = total + [l]
				l = []
		else:
			for j in range(tmp):
				l = l + [sig.format(j,i)]
			else:
				total = total + [l]
				l = []
		

with open("input_matrix.txt","w") as fileout:
	fileout.write(json.dumps(total))
