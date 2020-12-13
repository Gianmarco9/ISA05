#! /env/python

import json
import math
import sys

if len(sys.argv) != 3:
	print("[ERROR]: wrong number of arguments")
	sys.exit(-1)

word_len = int(sys.argv[1])
radix = int(sys.argv[2])

#word_len = int(input("How many bits do the operands have?\t"))
#radix = int(input("Radix factor:\t"))

# the bit comprised into the radix multiplication
n_bits_radix = math.log2(radix)
# the number of operands of the starting point level
n_operands = math.ceil(word_len / n_bits_radix) + 1


# matrix used as a map for the bit precence/significance entering a dadda level
prev_matrix = []
# matrix used as a map for the signal (and thus its presence) exiting a dadda level
next_matrix = [[]]*word_len

# dadda operands per level
d_level = []

# the length of the operators
first_op_len = word_len + 1 + 3
central_op_len = word_len + 1 + 2 + 2
secondlast_op_len = word_len + 1 + 1 + 2 
last_op_len = word_len + 2

# list of strings to be printed on the output VHDL file
list_of_sig = []
list_of_comp_and_comm= [] + ["\nBEGIN\n"]

# creates a signal of std_logic_vector everytime a new connection has to be done
def add_signal(name):
	global list_of_sig
	list_of_sig = list_of_sig + ["SIGNAL {}: std_logic;\n".format(name)]

sig_string = "{}_lev{}_col{}_inst{}_port_{}"
#def add_signal(name, size):
#	global list_of_sig
#	list_of_sig = list_of_sig + ["SIGNAL {}: std_logic_vector({} DOWNTO 0);".format(name, int(size)-1)]

# instantiates a full adder 
def add_fa(instance, in_a, in_b, in_c, out_s, out_c):
	global list_of_comp_and_comm
	list_of_comp_and_comm = list_of_comp_and_comm + ["{}: FA PORT MAP({}, {}, {}, {}, {});\n".format(instance, in_a, in_b, in_c, out_s, out_c)]

fa_string = "FA_lev{}_col{}_inst{}"

# instantiates an half adder
def add_ha(instance, in_a, in_b, out_s, out_c):
	global list_of_comp_and_comm
	list_of_comp_and_comm = list_of_comp_and_comm + ["{}: HA PORT MAP({}, {}, {}, {});\n".format(instance, in_a, in_b, out_s, out_c)]

ha_string = "HA_lev{}_col{}_inst{}"

# add a comment
def add_comment(comment):
	global list_of_comp_and_comm
	list_of_comp_and_comm = list_of_comp_and_comm + ["\n-- {}\n".format(comment)]

# create a list of the number of the operands for the next level
def dadda_leveler(max_ops):
	global d_level
	d = 2
	while d <= max_ops:
		d_level = d_level + [d]
		d = math.floor(3 * d / 2)
	d_level = sorted(d_level, reverse=True)
	
def header():
	return """LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

"""

def entity():
    return """ENTITY dadda_tree IS
PORT(	PP_IN: IN DADDA_ARRAY;
	PP_OUT1:OUT STD_LOGIC_VECTOR(n_prod-1 DOWNTO 0);
	PP_OUT2:OUT STD_LOGIC_VECTOR(n_prod-1 DOWNTO 0)
);
END ENTITY;


ARCHITECTURE struct OF dadda_tree IS

"""
	
def add_comp_decl():
	return """COMPONENT FA 
PORT(	A: IN STD_LOGIC;
	B: IN STD_LOGIC;
	Ci: IN STD_LOGIC;
	S: OUT STD_LOGIC;
	Co: OUT STD_LOGIC);
END COMPONENT;
	
COMPONENT HA 
PORT(	A: IN STD_LOGIC;
	B: IN STD_LOGIC;
	S: OUT STD_LOGIC;
	Co: OUT STD_LOGIC);
END COMPONENT;

"""

# concatenate the columns bit to obtain 2 rows of std_logic_vector
def out_conn():
	out1 = ""
	out2 = ""
	for i in sorted(range(1,len(next_matrix)), reverse=True):
		out1 = out1 + " " + next_matrix[i][0] + " " + "&"
		if i != 1:
			out2 = out2 + " " + next_matrix[i][1] + " " + "&"
		else:
			out2 = out2 + " " + "'0'" + " " + "&"
	else:
		out1 = out1 + " " + next_matrix[0][0]
		out2 = out2 + " " + next_matrix[0][1]
	return "\n\nPP_OUT1 <= {};\n\n".format(out1) + "PP_OUT2 <= {};\n\n".format(out2)

### LAST ADDER TO BE IMPLEMENTED
def footer():
	return """END ARCHITECTURE;"""
	
def printer():
	global next_matrix
	for _ in next_matrix:
		print(_)
# list which tracks down the added carries to be taken into account for the next step
#list_of_carries = [0]*word_len*2
	
# reorder the matrix in the shape of a triangle
# def pyramid():
#	global prev_matrix
	
# the number of bits reduced using that component on the column
fa_s = 3 - 1
ha_s = 2 - 1
# the number of bits added on the next column using that component on the column
fa_c = 1
ha_c = 1


# algorithm START
print("This is an unlicensed script made by Luca Lombardini\nContacts: s277972@studenti.polito.it")

print("Fetching matrix...")
try:
	with open("input_matrix.txt","r") as filein:
		next_matrix = json.load(filein)
except FileNotFoundError:
	print("[ ERROR ]: input file not found!")
	exit()
else:
	print("Done")

with open("../src/multiplier/mbe/dadda_tree.vhd", "w") as sourceOut:
	sourceOut.write(header())
	sourceOut.write(entity())
	sourceOut.write(add_comp_decl())
	
	dadda_leveler(n_operands)
	print(d_level)
	level_index = 0
	# loop on the levels
	for next_ops in d_level:
		level_number = len(d_level) - level_index
		print("Compiling level {}".format(level_number + 1))
		add_comment("Level no {}".format(level_number + 1))
		for col in range(len(next_matrix)):
			print("\tStarting iteration on column {}".format(col))
			valid_ops = len(next_matrix[col])
			delta = valid_ops - next_ops
			instance_no = 0
			candidate_index = 0								# index of the first bit operand taken as input for FA/HA
			sum_index = 0									# index of the position in the column where the result will be placed
			op_offset = 0
			while delta > 0:			# is the reduction needed?
				print("\t\tPre-proc Col{}_elements: \t".format(col),len(next_matrix[col]))
				print(next_matrix[col])
				print("\t\tExceeding bits: {}".format(delta))
				if delta - fa_s >= 0:		# is a FA too much?
					print("\t\t\tInstancing one more FA")
					delta = len(next_matrix[col]) - next_ops - fa_s
					sig_a = next_matrix[col][sum_index + 0]				# there are candidates: these becomes the new inputs
					sig_b = next_matrix[col][sum_index + 1]
					sig_cin=next_matrix[col][sum_index + 2]
					#candidate_index = candidate_index + 1					# don't reuse the same bits for the next unit!!!!!
					op_offset = 3
					print("\t\t\t\tLoading signal from the previous level: {}\n\t\t\t\t{}\n\t\t\t\t{}".format(sig_a,sig_b,sig_cin))
					sig_s = sig_string.format("FA",level_number,col,instance_no,"S")	# these 2 are new candidates as new inputs, one for this col and for the next
					sig_cout=sig_string.format("FA",level_number,col,instance_no,"COUT")
					print("\t\t\t\tCreating new output signals: {}\n\t\t\t\t{}".format(sig_s,sig_cout))
					add_signal(sig_s)							# add declaration to ARCHITECTURE
					add_signal(sig_cout)
					unit_name = fa_string.format(level_number,col,instance_no)
					add_fa(unit_name, sig_a, sig_b, sig_cin, sig_s, sig_cout)
					
				elif delta - ha_s >= 0:	# is a HA too much?
					print("\t\t\tInstancing one more HA")
					delta = len(next_matrix[col]) - next_ops - ha_s
					sig_a = next_matrix[col][sum_index + 0]
					sig_b = next_matrix[col][sum_index + 1]
					#candidate_index = candidate_index + 1
					op_offset = 2
					print("\t\t\t\tLoading signal from the previous level: {}\n\t\t\t\t{}".format(sig_a,sig_b))
					sig_s = sig_string.format("HA",level_number,col,instance_no,"S")
					sig_cout=sig_string.format("HA",level_number,col,instance_no,"COUT")
					print("\t\t\t\tCreating new output signals: {}\n\t\t\t\t{}".format(sig_s,sig_cout))
					add_signal(sig_s)							# add declaration to ARCHITECTURE
					add_signal(sig_cout)
					unit_name = ha_string.format(level_number,col,instance_no)
					add_ha(unit_name, sig_a, sig_b, sig_s, sig_cout)

				# relocate the bits for the next assignation
				#print("Relocating the signals\nCol: {}\t".format(col),next_matrix[col],"\nCol: {}\t".format(col+1),next_matrix[col+1])
				next_matrix[col][sum_index + 0] = sig_s				# the sum bits are alligned to the upmost side and scaled by 1 everytime 1 FA is added
				if col < word_len*2 - 1:
					next_matrix[col + 1] = next_matrix[col + 1] + [sig_cout]		# add the carry at the bottom of the list: this helps reducing the delay (exclude ripple same level)
				instance_no = instance_no + 1
				#next_matrix[col] = next_matrix[col][:sum_index] + next_matrix[col][op_offset:]		# reallocation: compress keeping the new sum bits and the previous unused stacked signals
				next_matrix[col] = next_matrix[col][:sum_index + 1] + next_matrix[col][sum_index + op_offset:]		# reallocation: compress keeping the new sum bits and the previous unused stacked signals
				print(sum_index)
				print(next_matrix[col])
				sum_index = sum_index + 1
				#print("Result\nCol{}_elements: \t".format(col),next_matrix[col])
				#print("cand_index = {}\nsum_index = {}\n".format(candidate_index,sum_index))
				#printer()
			else:
				print("\t\tPost-proc Col{}_elements: \t".format(col),len(next_matrix[col]))
				print("\t\tInstanced component for this col: {}\n\n".format(instance_no))

		level_index = level_index + 1	
	else:
		pass
		# instantiates the last adder

	for signal_decl in list_of_sig:
		sourceOut.write(signal_decl)
		
	for comp_and_comm in list_of_comp_and_comm:
		sourceOut.write(comp_and_comm)
	
	sourceOut.write(out_conn())
	sourceOut.write(footer())
