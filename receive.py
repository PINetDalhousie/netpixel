#!/usr/bin/env python3
import sys
import struct
import os

from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet, IPOption
from scapy.all import ShortField, IntField, LongField, BitField, FieldListField, FieldLenField
from scapy.all import IP, TCP, UDP, Raw
from scapy.layers.inet import _IPOption_HDR



def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface

class IPOption_MRI(IPOption):
    name = "MRI"
    option = 31
    fields_desc = [ _IPOption_HDR,
                    FieldLenField("length", None, fmt="B",
                                  length_of="swids",
                                  adjust=lambda pkt,l:l+4),
                    ShortField("count", 0),
                    FieldListField("swids",
                                   [],
                                   IntField("", 0),
                                   length_from=lambda pkt:pkt.count*4) ]
def handle_pkt(pkt):
    if UDP in pkt and pkt[UDP].dport>9999:
        print("got packet")
        if Raw in pkt:
            str=pkt[Raw].load
            counter=struct.unpack('8B',str)


            class_decision=counter[0]*256**3+counter[1]*256**2+counter[2]*256**1+counter[3]
            sqn=counter[4]*256**3+counter[5]*256**2+counter[6]*256**1+counter[7]

            if (pkt[UDP].sport==10000 or sqn%1000==0):
                f=open("labels.txt","r")
                labels=[line.rstrip(";\n") for line in f]
                f.close()
                print("Class Decision\t\tPackets")
                print(labels[class_decision],end=" \t\t\t")
                print(sqn)
            sys.stdout.flush()
    

def main():
    ifaces = list(filter(lambda i: 'eth' in i, os.listdir('/sys/class/net/')))
    #iface = ifaces[0]
    iface='veth2'
    print("sniffing on %s" % iface)
    sys.stdout.flush()
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))
if __name__ == '__main__':
    main()
