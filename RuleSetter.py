#!/usr/bin/env python3

all_features=["colors","low_intensity", "mid_intensity", "high_intensity", "edge_count","brightness","contrast"]

fwdlines=[]
forwarding=open("forwarding.txt","r")
for line in forwarding:
	fwdlines.append(line)
forwarding.close()
f=open("tree.txt","r")
lines=[line.rstrip(";\n") for line in f]
f.close()

writer=open("s1-runtime.json","w")
for line in fwdlines:
	writer.write(line)

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
	writer.write(",\n")
	writer.write("    {\n")
	writer.write("      \"table\": \"MyIngress.decision_table\",\n")
	writer.write("     \"match\": {\n")
	writer.write("        \"feature1\": ["+str(lows[0])+","+str(highs[0])+"],\n")
	writer.write("        \"feature2\": ["+str(lows[1])+","+str(highs[1])+"],\n")
	writer.write("        \"feature3\": ["+str(lows[2])+","+str(highs[2])+"],\n")
	writer.write("        \"feature4\": ["+str(lows[3])+","+str(highs[3])+"],\n")
	writer.write("        \"feature5\": ["+str(lows[4])+","+str(highs[4])+"],\n")
	writer.write("        \"feature6\": ["+str(lows[5])+","+str(highs[5])+"],\n")
	writer.write("        \"feature7\": ["+str(lows[6])+","+str(highs[6])+"]\n")
	writer.write("      },\n")
	writer.write("      \"action_name\": \"MyIngress.class_value\",\n")
	writer.write("      \"action_params\": {\n")
	writer.write("        \"value\": "+str(class_value)+"\n")
	writer.write("      },\n")
	writer.write("      \"priority\": 1\n")
	writer.write("    }")
writer.write("")
writer.write("")
writer.close()


