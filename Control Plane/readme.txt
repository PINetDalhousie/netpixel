======================================
	Install requirements
======================================

This is a Python 3 based project. It requires the following modules:
	fxpmath
	pydotplus
	pandas
	sklearn
	matplotlib

To install the requirements run "sudo pip3 install fxpmath pydotplus pandas sklearn matplotlib"	

======================================
	Run
======================================

Unzip the MNIST27.zip to get the imageset

Open "MakeDataset.py" in a text editor
Replace line 20-
  for f in glob.iglob("Imagenet/*"):
with-
  for f in glob.iglob("MNIST27/*"):
  
also replace line 23-
  iname=iname.replace("Imagenet/","")
with-
  iname=iname.replace("MNIST27/","")
  
Run MakeDataset.py
Run Randomizer.py
Run MakeTree.py

Rules are stored in tree.txt file
