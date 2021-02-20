#! /env/python

import sys


OUTPUT_FILENAME="../sim/cpu_state"

if len(sys.argv) != 2:
	print("[ERROR]: wrong number of arguments")
	sys.exit(-1)
	
INPUT_FILENAME=sys.argv[1]

if "_" in INPUT_FILENAME:
	OUTPUT_FILENAME += "_" + INPUT_FILENAME.split("_")[-1]
	flag = 1
else:
	OUTPUT_FILENAME += ".txt"
	flag = 0

class cpu_state():
	def __init__(self):
		
		if flag:
			self.map = {"CLOCK":0, "PC":"", "OP":"", "RD":"", "RS1":"", "RS2":"", "IMM":"", "NOP_inj":"", "ALU_FORW1":"", "ALU_FORW2":"", "NEW_ADDR":"", "ALU_RES":"", "ABS_RES":"", "ADDR_MEM":"", "DATA_W_MEM":"", "DATA_R_MEM":"", "WR":"", "RD_ADDR":"", "WR_DATA":""}
		else:
			self.map = {"CLOCK":0, "PC":"", "OP":"", "RD":"", "RS1":"", "RS2":"", "IMM":"", "NOP_inj":"", "ALU_FORW1":"", "ALU_FORW2":"", "NEW_ADDR":"", "ALU_RES":"", "ADDR_MEM":"", "DATA_W_MEM":"", "DATA_R_MEM":"", "WR":"", "RD_ADDR":"", "WR_DATA":""}
			
		self.instruction = ["null", "null", "null", "null"]

	def __str__(self):
		separators = {"CLOCK":"CYCLE No:\t", "PC":"\t- fetch stage instr:", "OP":"\t- decode stage instr:", "NOP_inj":"\t- execute stage instr:", "ADDR_MEM":"\t- mem stage instr:", "WR":"\t- wrback stage instr:"}
		n_chars = max([len(v) for k,v in separators.items()])
		ignore_list = ["OP", "RD", "RS1", "RS2", "IMM"]
		outstring = ""
		index = 0
		for key, value in self.map.items():				# iterate through the dictionary-map elements
			if key in separators.keys():				# is one of the keys preceeded by a particular string
				outstring += separators[key]			# if so, add it
				if key == "CLOCK":				# the clock one needs the key's value
					outstring += "\t\t" + str(value) + "\n"
				elif key != "PC":
					outstring += "\t" + self.instruction[index] + "\n"
					index += 1
				else:
					outstring += "\n"
			if key != "CLOCK" and key not in ignore_list:
				outstring += "\t\t" + format(key + ":", '<'+str(n_chars-8)) + value + "\n"
		return outstring
    
	def modify(self, line_no, line_in):
		tmp_line = line_in.rstrip("\n").rstrip("_")
		if tmp_line == "CLOCK":						# new machine cycle
			self.map[tmp_line] += 1
		else:
			self.map[list(self.map.keys())[line_no - line_no // self.states_enum() * self.states_enum()]] = tmp_line	# add signal value to the record
        	
	def states_enum(self):
		return len(self.map.keys())					# how many signals are there
		
	def generate_instr(self):
		if self.map["OP"] in ["ADD", "XOR", "SLT"]:
			new_instr = self.map["OP"] + " x{}, x{}, x{}".format(self.map["RD"], self.map["RS1"], self.map["RS2"])
		elif self.map["OP"] in ["ADDI", "SRAI", "ANDI", "LW"]:
			new_instr = self.map["OP"] + " x{}, x{}, 0x{}".format(self.map["RD"], self.map["RS1"], self.map["IMM"])
		elif self.map["OP"] in ["ABS"]:
			new_instr = self.map["OP"] + " x{}, x{}".format(self.map["RD"], self.map["RS1"])
		elif self.map["OP"] in ["BEQ"]:
			new_instr = self.map["OP"] + " x{}, x{}, 0x{}".format(self.map["RS1"], self.map["RS2"], self.map["IMM"])
		elif self.map["OP"] in ["LW"]:
			new_instr = self.map["OP"] + " x{}, 0x{}(x{})".format(self.map["RD"], self.map["IMM"], self.map["RS1"])
		elif self.map["OP"] in ["SW"]: 
			new_instr = self.map["OP"] + " x{}, 0x{}(x{})".format(self.map["RS1"], self.map["IMM"], self.map["RS2"])
		elif self.map["OP"] in ["LUI", "AUIPC", "JAL"]:
			new_instr = self.map["OP"] + " x{}, 0x{}".format(self.map["RD"], self.map["IMM"])
		elif self.map["OP"] in ["dummy"]:
			new_instr = ""
		elif self.map["OP"] == "NOP":
			new_instr = "NOP"
		else:
			new_instr = "err"
			print("[ ERROR ]: Invalid Instruction")
		return new_instr
		
	def pipe_adv(self, new_instr):
		if self.map["NOP_inj"] == '1':
			self.instruction = [new_instr] + ["NOP"] + self.instruction[1:-1]
		else:
			self.instruction = [new_instr] + self.instruction[:-1]
		

record = cpu_state()

with open(INPUT_FILENAME, 'r') as filein, open(OUTPUT_FILENAME, 'w') as fileout:
	for no, line in enumerate(filein):
		if no > 0 and not no % record.states_enum():
			record.pipe_adv(record.generate_instr())
			fileout.write(record.__str__() + "\n\n")
		record.modify(no, line)
	record.pipe_adv(record.generate_instr())
	fileout.write(record.__str__())
