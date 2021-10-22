#!/usr/bin/env python3

from fxpmath import Fxp
import math

f=open("sample.txt", "w")
array=[]
for i in range(256):
	array.append(i)
	if (i==0):
		continue
	num=math.log(i,2)
	x = Fxp(num, signed=False, n_word=32, n_frac=4)
	f.write("    {\n")
	f.write("      \"table\": \"MyIngress.logmatch\", \n")
	f.write("      \"match\": {\n")
	f.write("        \"tester\": ["+str(i)+"]\n")
	f.write("      },\n")
	f.write("      \"action_name\": \"MyIngress.set_port\",\n")
	f.write("      \"action_params\": {\n")
	f.write("        \"newval\": "+str(x.val)+"\n")
	f.write("      }\n")
	f.write("    },\n")
	#f.write(x.hex()+"\n")
f.close()
