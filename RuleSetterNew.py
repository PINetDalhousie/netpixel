#!/usr/bin/env python3

all_features=["colors","low_intensity", "mid_intensity", "high_intensity", "edge_count","brightness","contrast"]
f=open("tree.txt","r")
lines=[line.rstrip(";\n") for line in f]
f.close()
writer2=open("commands.txt","w")
writer2.write("table_set default forwarding drop\n")
writer2.write("table_add forwarding set_port 50000 => 2\n.")

for line in lines:
	print(line)
	lows=["0", "0", "0", "0", "0", "0", "0"]
	highs=["999999", "999999", "999999", "999999", "999999", "999999", "999999"] 
	sets=[]
	features=[]
	operators=[]
	nums=[]
	sets=line.split()
	sets=list(dict.fromkeys(sets))
	sets.remove("and")
	sets.remove("when")
	sets.remove("then")
	#print(sets)
	for member in sets:
		if "<=" in member:
			temp=member.split("<=")
			features.append(temp[0])
			operators.append("le")
			nums.append(temp[1])
		elif "<" in member:
			temp=member.split("<")
			features.append(temp[0])
			operators.append("l")
			nums.append(temp[1])
		elif ">=" in member:
			temp=member.split(">=")
			features.append(temp[0])
			operators.append("ge")
			nums.append(temp[1])
		elif ">" in member:
			temp=member.split(">")
			features.append(temp[0])
			operators.append("g")
			nums.append(temp[1])
		else:
			class_value=int(member)	
	i=0
	for feature in features:
		idx=all_features.index(feature)
		if operators[i]=="le":
			current=float(highs[idx])
			new=float(nums[i])
			if new < current:
				highs[idx]=int(new)
		if operators[i]=="l":
			current=float(highs[idx])
			new=float(nums[i])
			if new < current:
				highs[idx]=int(new)-1
		if operators[i]=="ge":
			current=float(lows[idx])
			new=float(nums[i])
			if new > current:
				lows[idx]=int(new)
		if operators[i]=="g":
			current=float(lows[idx])
			new=float(nums[i])
			if new > current:
				lows[idx]=int(new)+1
		i=i+1
	
	writer2.write("table_add decision_table class_value"+" "+str(lows[0])+"->"+str(highs[0])+" "+str(lows[1])+"->"+str(highs[1])+" "+str(lows[2])+"->"+str(highs[2])+" "+str(lows[3])+"->"+str(highs[3])+" "+str(lows[4])+"->"+str(highs[4])+" "+str(lows[5])+"->"+str(highs[5])+" "+str(lows[6])+"->"+str(highs[6])+" "+"=> "+str(class_value)+" 1\n")
writer2.close()


