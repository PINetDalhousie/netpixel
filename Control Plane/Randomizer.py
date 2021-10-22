import random

filew=open("dataset.txt","r")
data=[]
for line in filew:
    data.append(line)
filew.close()
random.shuffle(data)
filetr=open("datatrain.txt","w")
filete=open("datatest.txt","w")
i=0
for line in data:
    if (i%10==0):
        filete.write(str(line))
    else:
        filetr.write(str(line))
    i=i+1
filetr.close()
filete.close()
