# netpixel
1. Download the P4 Virtual Machine from: https://p4.org/events/2019-04-30-p4-developer-day/

2. Clone this repository from: https://github.com/hisham-sid/Image_Classification (use git clone [name of the repositoy])

3. Run the veth_setup.sh script: 
    cd Image_Classification 
    chmod +x veth_setup.sh ./veth_setup.sh

4. Next, navigate to the Control Plane folder using cd.

5. Follow the instructions in readme.txt in Control Plane folder to generate the tree.txt file

6. Copy the tree.txt file from Control Plane folder to original folder cd .. cp ./Control Plane/tree.txt ./

7. Run RuleSetterNew.py script: python3 RuleSetterNew.py

8. Open 4 terminals in the Image_Classification folder

  In terminal 1: p4c --target bmv2 --arch v1model basic.p4 sudo simple_switch_grpc -i 1@veth1 -i 2@veth2 --log-console basic.json

  In terminal 2: sudo simple_switch_CLI --thrift-port 9090 < commands.txt

  In terminal 3 (we will use this as host 2): sudo python3 receive.py

  In terminal 4 (we will use this as host 1): sudo python3 send.py 10.0.2.2 [name of the image]
