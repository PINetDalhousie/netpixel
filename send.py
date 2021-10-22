#!/usr/bin/env python3
import argparse
import sys
import socket
import random
import struct
import time

#Pillow for image processing
from PIL import Image
from scapy.all import sendp, send, get_if_list, get_if_hwaddr
from scapy.all import *

class Colors(Packet):
    name = "Colors "
    fields_desc=[ XByteField("red1",0),
                 XByteField("green1",0),
                 XByteField("blue1",0),
                 XByteField("red2",0),
                 XByteField("green2",0),
                 XByteField("blue2",0),
                 XByteField("red3",0),
                 XByteField("green3",0),
                 XByteField("blue3",0),
                 XByteField("red4",0),
                 XByteField("green4",0),
                 XByteField("blue4",0),
                 XByteField("red5",0),
                 XByteField("green5",0),
                 XByteField("blue5",0),
                 XByteField("red6",0),
                 XByteField("green6",0),
                 XByteField("blue6",0),
                 XByteField("red7",0),
                 XByteField("green7",0),
                 XByteField("blue7",0),
                 XByteField("red8",0),
                 XByteField("green8",0),
                 XByteField("blue8",0),
                 XByteField("red9",0),
                 XByteField("green9",0),
                 XByteField("blue9",0),]

class Counts(Packet):
    name="Counts"
    fields_desc=[ BitField("class_decision",0,32),
                 BitField("sequence",10,32) ]

#getting the interface from the interface list
def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

def main():

   #ensuring two arguments are required
    if len(sys.argv)<3:
        print ('pass 2 arguments: <destination> "<image>"')
        exit(1)

    #acquire the MAC address of destination and interface
    addr = socket.gethostbyname(sys.argv[1])
    iface='veth1'
    #iface = get_if()
    print("sending on interface %s to %s" % (iface, str(addr)))

    #load the image provided in the argument, convert to RGB color pallette and extract dimensions
    image=Image.open(sys.argv[2])
    w,h=image.size
    if (w%3!=0):
        w=w+1
    if (w%3!=0):
        w=w+1
    if (h%3!=0):
        h=h+1
    if (h%3!=0):
        h=h+1
    image=image.resize((w,h))
    rgb_image=image.convert("RGB")
    

    sqn=1;

    s = conf.L2socket(iface=iface)
    count=0
    #iterate every pixel primarily by row and then column
    for j in range(0,h,3):
        for i in range(0,w,3):

            #get the RGB tuple at each pixel
            pixel1=rgb_image.getpixel((i,j))
            pixel2=rgb_image.getpixel((i+1,j))
            pixel3=rgb_image.getpixel((i+2,j))
            pixel4=rgb_image.getpixel((i,j+1))
            pixel5=rgb_image.getpixel((i+1,j+1))
            pixel6=rgb_image.getpixel((i+2,j+1))
            pixel7=rgb_image.getpixel((i,j+2))
            pixel8=rgb_image.getpixel((i+1,j+2))
            pixel9=rgb_image.getpixel((i+2,j+2))

	    #retrieve the integer values of the R,G and B colors
            redC1,greenC1,blueC1=pixel1
            redC2,greenC2,blueC2=pixel2
            redC3,greenC3,blueC3=pixel3
            redC4,greenC4,blueC4=pixel4
            redC5,greenC5,blueC5=pixel5
            redC6,greenC6,blueC6=pixel6
            redC7,greenC7,blueC7=pixel7
            redC8,greenC8,blueC8=pixel8
            redC9,greenC9,blueC9=pixel9

	    #include the color values as a custom header named Colors, send it to the destination
            time.sleep(0.001)
            pkt =  Ether(src=get_if_hwaddr(iface), dst='ff:ff:ff:ff:ff:ff')
            pkt = pkt /IP(dst=addr) / UDP(dport=50000, sport=50001)/Colors(red1=redC1,green1=greenC1,blue1=blueC1,red2=redC2,green2=greenC2,blue2=blueC2,red3=redC3,green3=greenC3,blue3=blueC3,red4=redC4,green4=greenC4,blue4=blueC4,red5=redC5,green5=greenC5,blue5=blueC5,red6=redC6,green6=greenC6,blue6=blueC6,red7=redC7,green7=greenC7,blue7=blueC7,red8=redC8,green8=greenC8,blue8=blueC8,red9=redC9,green9=greenC9,blue9=blueC9)/Counts(sequence=sqn)
            #pkt.show()
            count=count+1
            if (count%1000==0):
                pkt.show()
            sqn=sqn+1
            s.send(pkt)
	
    pkt2 =  Ether(src=get_if_hwaddr(iface), dst='ff:ff:ff:ff:ff:ff')
    pkt2= pkt2 /IP(dst=addr) / UDP(dport=50000, sport=10000)/Colors()/Counts(class_decision=10,sequence=sqn)  
    pkt2.show()
    sendp(pkt2, iface=iface, verbose=False)
if __name__ == '__main__':
    main()
