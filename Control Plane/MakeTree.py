#!/usr/bin/env python3
import numpy as np
import pandas as pd
import argparse
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import export_text
from sklearn.metrics import accuracy_score
from sklearn.tree import export_graphviz
import pydotplus

# output the tree
def get_lineage(tree, feature_names, file):
    colors=[];
    low_intensity=[]
    mid_intensity=[]
    high_intensity=[]
    edge_count=[]
    brightness=[]
    contrast=[]
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = [feature_names[i] for i in tree.tree_.feature]
    value = tree.tree_.value
    le = '<='
    g = '>'
    # get ids of child nodes
    idx = np.argwhere(left == -1)[:, 0]
    
    # traverse the tree and get the node information
    def recurse(left, right, child, lineage=None):
        if lineage is None:
            lineage = [child]
        if child in left:
            parent = np.where(left == child)[0].item()
            split = 'l'
        else:
            parent = np.where(right == child)[0].item()
            split = 'r'
      
        lineage.append((parent, split, threshold[parent], features[parent]))

        if parent == 0:
            lineage.reverse()
            return lineage
        else:
            return recurse(left, right, parent, lineage)

    for j, child in enumerate(idx):
        clause = ' when '
        for node in recurse(left, right, child):
                #if len(str(node)) < 3:
                if str(node).find('(') != 0:
                    continue
                i = node
                
                if i[1] == 'l':
                    sign = le
                else:
                    sign = g
                clause = clause + i[3] + sign + str(i[2]) + ' and '
    
    # wirte the node information into text file
        a = list(value[node][0])
        ind = a.index(max(a))
        clause = clause[:-4] + ' then ' + str(ind)
        file.write(clause)
        file.write(";\n")

# Training set X and Y
Set1 = pd.read_csv('datatrain.txt',header=None)
Set = Set1.values.tolist()
X = [i[0:7] for i in Set]
Y =[i[7] for i in Set]

# Test set Xt and Yt
Set2 = pd.read_csv('datatest.txt',header=None)
Sett = Set2.values.tolist()
Xt = [i[0:7] for i in Set]
Yt =[i[7] for i in Set]

feature_names=['colors','low_intensity','mid_intensity','high_intensity','edge_count','brightness','contrast']

# prepare training and testing set
X = np.array(X)
Y = np.array(Y)
Xt = np.array(Xt)
Yt = np.array(Yt)

# decision tree fit
dt = DecisionTreeClassifier(max_depth = 10)
dt.fit(X, Y)

Predict_Y = dt.predict(X)
print(accuracy_score(Y, Predict_Y))

Predict_Yt = dt.predict(Xt)
print(accuracy_score(Yt, Predict_Yt))

#testcase=[18696,3901,10461,8138,1289,2258,15]
##testcase=np.array(testcase)
#testcase=testcase.reshape(1,-1)
#case=dt.predict(testcase)
#print(testcase)
#print(case)

# output the tree in a text file, write it
threshold = dt.tree_.threshold
features  = [feature_names[i] for i in dt.tree_.feature]
colors=[];
low_intensity=[]
mid_intensity=[]
high_intensity=[]
edge_count=[]
brightness=[]
contrast=[]
for i, fe in enumerate(features):
    if fe == 'colors':
        colors.append(threshold[i])
    elif fe == 'low_intensity':
        if threshold[i] != -2.0:
            low_intensity.append(threshold[i])
    elif fe == 'mid_intensity':
        if threshold[i] != -2.0:
            mid_intensity.append(threshold[i])
    elif fe == 'high_intensity':
        if threshold[i] != -2.0:
            high_intensity.append(threshold[i])
    elif fe == 'edge_count':
        if threshold[i] != -2.0:
            high_intensity.append(threshold[i])
    elif fe == 'brightness':
        if threshold[i] != -2.0:
            high_intensity.append(threshold[i])
    else:
        contrast.append(threshold[i])
tree = open("tree.txt","w+")
get_lineage(dt,feature_names,tree)
tree.close()
