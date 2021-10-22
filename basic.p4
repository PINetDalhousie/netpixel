/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>
#include "NPmath.p4"

const bit<16> TYPE_IPV4 = 0x800;


#define BLOOM_FILTER_ENTRIES 4445000
#define BLOOM_FILTER_BIT_WIDTH 1

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> length_;
    bit<16> checksum;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header colors_t {
	bit<8> red1;
	bit<8> green1;
	bit<8> blue1;

	bit<8> red2;
	bit<8> green2;
	bit<8> blue2;

	bit<8> red3;
	bit<8> green3;
	bit<8> blue3;

	bit<8> red4;
	bit<8> green4;
	bit<8> blue4;

	bit<8> red5;
	bit<8> green5;
	bit<8> blue5;

	bit<8> red6;
	bit<8> green6;
	bit<8> blue6;

	bit<8> red7;
	bit<8> green7;
	bit<8> blue7;

	bit<8> red8;
	bit<8> green8;
	bit<8> blue8;

	bit<8> red9;
	bit<8> green9;
	bit<8> blue9;
}

header counts_t {
	bit<32> class_decision;
	bit<32> sequence;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    udp_t udp;
    colors_t colors;
    counts_t counts;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        //transition parse_tcp;
        transition parse_udp;
    }
    
    state parse_udp {
        packet.extract(hdr.udp);
        transition parse_color;
    }

    state parse_color {
        packet.extract(hdr.colors);
        transition parse_counts;
     }
    state parse_counts {
        packet.extract(hdr.counts);
	transition accept;
    }	

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    //feature1 colors
   register<bit<BLOOM_FILTER_BIT_WIDTH>>(BLOOM_FILTER_ENTRIES) bloom_filter;
   bit<32> filter_address;
   bit<1> filter_value;  
   
    //feature2,3,4 low,mid,high intensity
   register<bit<32>>(3) gray_reg;
   bit<32> low_gray;
   bit<32> mid_gray;
   bit<32> high_gray;
   bit<32> low_ratio=32w0;
   bit<32> mid_ratio=32w0;
   bit<32> high_ratio=32w0; 

   //feature6,7 brightness, contrast
   register<bit<32>>(1) count_reg;
   register<bit<32>>(1) count_intensity;
   bit<32>count;
   bit<32> gray_pixel1=32w0;
   bit<32> gray_pixel2=32w0;
   bit<32> gray_pixel3=32w0;
   bit<32> gray_pixel4=32w0;
   bit<32> gray_pixel5=32w0;
   bit<32> gray_pixel6=32w0;
   bit<32> gray_pixel7=32w0;
   bit<32> gray_pixel8=32w0;
   bit<32> gray_pixel9=32w0;
   bit<32> intensity_count=32w0;
   bit<32> brightness=32w0;
   
    //feature7 contrast
    register<bit<32>>(2) gray_maxmin;
    bit<32> min_gray=32w99999;
    bit<32> max_gray=32w0;
    bit<32> contrast=32w0;  
    register<bit<32>>(1) packets;
    bit<32> packetno=32w0; 

    //feature5 edge_count
    register<int<32>>(1) laplace_prev;
    register<bit<32>>(1) count_edge;
    bit<32> edge_count;
    int<32> prev_laplace;
    int<32> laplace;


		   
    div() DivBrightness;
    div() DivContrast;
    div() DivLowIntensity;
    div() DivMidIntensity;
    div() DivHighIntensity;

    mul() MulRed1;
    mul() MulGreen1;
    mul() MulBlue1;

    mul() MulRed2;
    mul() MulGreen2;
    mul() MulBlue2;

    mul() MulRed3;
    mul() MulGreen3;
    mul() MulBlue3;

    mul() MulRed4;
    mul() MulGreen4;
    mul() MulBlue4;

    mul() MulRed5;
    mul() MulGreen5;
    mul() MulBlue5;

    mul() MulRed6;
    mul() MulGreen6;
    mul() MulBlue6;

    mul() MulRed7;
    mul() MulGreen7;
    mul() MulBlue7;

    mul() MulRed8;
    mul() MulGreen8;
    mul() MulBlue8;

    mul() MulRed9;
    mul() MulGreen9;
    mul() MulBlue9;

    bit<32> final_class=32w0;
    bit<32> feature1=32w0;
    bit<32> feature2=32w0;
    bit<32> feature3=32w0;
    bit<32> feature4=32w0;
    bit<32> feature5=32w0;
    bit<32> feature6=32w0;
    bit<32> feature7=32w0;

    action drop() {
        mark_to_drop(standard_metadata);
    }

     action compute_hashes(bit<8> colorR, bit<8> colorG, bit<8> colorB){
       //here all the colors are considered to create a hash address for the register position
       hash(filter_address, HashAlgorithm.crc32, (bit<32>)0, {colorR,
                                                           colorG,
                                                           colorB},
                                                           (bit<32>)BLOOM_FILTER_ENTRIES);

    }

    action set_port(egressSpec_t port) {
	standard_metadata.egress_spec=port;
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    action class_value(bit<32> value) {
	final_class=value;
    }
 
    table forwarding {
	key = {
		hdr.udp.dstPort: exact;
	}
	actions = {
		set_port;
		drop;
	}
    }

    table decision_table {
        key = {
            feature1: range;
	    feature2: range;
	    feature3: range;
	    feature4: range;
	    feature5: range;
	    feature6: range;
	    feature7: range;
        }
        actions = {
            class_value;
            NoAction;
        }
	size=20480;
    }	
    
    apply {

        if (hdr.ipv4.isValid()) {

	    packets.read(packetno,0);
	    packetno=packetno+1;
	    packets.write(0,packetno);

	    //read values from register, store in the variables
	    count_reg.read(count,0);
	    count_intensity.read(intensity_count,0);
	    count_edge.read(edge_count,0);
	    laplace_prev.read(prev_laplace,0);
	    gray_reg.read(low_gray,0);
	    gray_reg.read(mid_gray,1);
	    gray_reg.read(high_gray,2);
	    gray_maxmin.read(min_gray,0);
	    gray_maxmin.read(max_gray,1);


	  /*************************************************************************
	  *****************************  BLOOM FILTER  *****************************
	  *************************************************************************/
	    bit<32> red_M=32w6; //approx 0.299
	    bit<32> green_M=32w9; //approx 0.587
            bit<32> blue_M=32w2; //approx 0.114
	    bit<32> coeff_result=32w0;

	    //formula is gray=0.299*red + 0.587*green +0.114*blue, this is done for each pixel form the chunk
	   bit<32> red_C1=(bit<32>)hdr.colors.red1 << 4;
	   bit<32> green_C1=(bit<32>)hdr.colors.green1 << 4;
	   bit<32> blue_C1=(bit<32>)hdr.colors.blue1 << 4;
	   bit<32> red_C2=(bit<32>)hdr.colors.red2 << 4;
	   bit<32> green_C2=(bit<32>)hdr.colors.green2 << 4;
	   bit<32> blue_C2=(bit<32>)hdr.colors.blue2 << 4;
	   bit<32> red_C3=(bit<32>)hdr.colors.red3 << 4;
	   bit<32> green_C3=(bit<32>)hdr.colors.green3 << 4;
	   bit<32> blue_C3=(bit<32>)hdr.colors.blue3 << 4;
	   bit<32> red_C4=(bit<32>)hdr.colors.red4 << 4;
	   bit<32> green_C4=(bit<32>)hdr.colors.green4 << 4;
	   bit<32> blue_C4=(bit<32>)hdr.colors.blue4 << 4;
	   bit<32> red_C5=(bit<32>)hdr.colors.red5 << 4;
	   bit<32> green_C5=(bit<32>)hdr.colors.green5 << 4;
	   bit<32> blue_C5=(bit<32>)hdr.colors.blue5 << 4;
	   bit<32> red_C6=(bit<32>)hdr.colors.red6 << 4;
	   bit<32> green_C6=(bit<32>)hdr.colors.green6 << 4;
	   bit<32> blue_C6=(bit<32>)hdr.colors.blue6 << 4;
	   bit<32> red_C7=(bit<32>)hdr.colors.red7 << 4;
	   bit<32> green_C7=(bit<32>)hdr.colors.green7 << 4;
	   bit<32> blue_C7=(bit<32>)hdr.colors.blue7 << 4;
	   bit<32> red_C8=(bit<32>)hdr.colors.red8 << 4;
	   bit<32> green_C8=(bit<32>)hdr.colors.green8 << 4;
	   bit<32> blue_C8=(bit<32>)hdr.colors.blue8 << 4;
	   bit<32> red_C9=(bit<32>)hdr.colors.red9 << 4;
	   bit<32> green_C9=(bit<32>)hdr.colors.green9 << 4;
	   bit<32> blue_C9=(bit<32>)hdr.colors.blue9 << 4;
     
     
	    compute_hashes(hdr.colors.red1,hdr.colors.green1,hdr.colors.blue1);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red2,hdr.colors.green2,hdr.colors.blue2);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red3,hdr.colors.green3,hdr.colors.blue3);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red4,hdr.colors.green4,hdr.colors.blue4);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red5,hdr.colors.green5,hdr.colors.blue5);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red6,hdr.colors.green6,hdr.colors.blue6);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red7,hdr.colors.green7,hdr.colors.blue7);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red8,hdr.colors.green8,hdr.colors.blue8);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);

	    compute_hashes(hdr.colors.red9,hdr.colors.green9,hdr.colors.blue9);
	    //read the bloom filter value at that hashed address
	    bloom_filter.read(filter_value,filter_address);
	    //if its 0, that means its a new color, increment counter
	    if (hdr.udp.srcPort!=10000) {
	            if (filter_value==0 ) {
			    count=count+1;
		    }
	    }
    	    //if its new color, set the value as 1. If its old, the value is 1 anyways
	    bloom_filter.write(filter_address,1);
	  
	  /*************************************************************************
	  ****************** GRAYSCALE CONVERSION  *****************************
	  *************************************************************************/

	    MulRed1.apply(red_M,red_C1,coeff_result);
	    gray_pixel1=gray_pixel1+coeff_result;
	    MulGreen1.apply(green_M,green_C1,coeff_result);						//using color information to convert to grayscale value for pixel 1
	    gray_pixel1=gray_pixel1+coeff_result;
	    MulBlue1.apply(blue_M,blue_C1,coeff_result);
	    gray_pixel1=gray_pixel1+coeff_result;

	    MulRed2.apply(red_M,red_C2,coeff_result);
	    gray_pixel2=gray_pixel2+coeff_result;
	    MulGreen2.apply(green_M,green_C2,coeff_result);						//using color information to convert to grayscale value for pixel 2
	    gray_pixel2=gray_pixel2+coeff_result;
	    MulBlue2.apply(blue_M,blue_C2,coeff_result);
	    gray_pixel2=gray_pixel2+coeff_result;

	    MulRed3.apply(red_M,red_C3,coeff_result);
	    gray_pixel3=gray_pixel3+coeff_result;
	    MulGreen3.apply(green_M,green_C3,coeff_result);						//using color information to convert to grayscale value for pixel 3
	    gray_pixel3=gray_pixel3+coeff_result;
	    MulBlue3.apply(blue_M,blue_C3,coeff_result);
	    gray_pixel3=gray_pixel3+coeff_result;

	    MulRed4.apply(red_M,red_C4,coeff_result);
	    gray_pixel4=gray_pixel4+coeff_result;
	    MulGreen4.apply(green_M,green_C4,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel4=gray_pixel4+coeff_result;
	    MulBlue4.apply(blue_M,blue_C4,coeff_result);
	    gray_pixel4=gray_pixel4+coeff_result;

	    MulRed5.apply(red_M,red_C5,coeff_result);
	    gray_pixel5=gray_pixel5+coeff_result;
	    MulGreen5.apply(green_M,green_C5,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel5=gray_pixel5+coeff_result;
	    MulBlue5.apply(blue_M,blue_C5,coeff_result);
	    gray_pixel5=gray_pixel5+coeff_result;

	    MulRed6.apply(red_M,red_C6,coeff_result);
	    gray_pixel6=gray_pixel6+coeff_result;
	    MulGreen6.apply(green_M,green_C6,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel6=gray_pixel6+coeff_result;
	    MulBlue6.apply(blue_M,blue_C6,coeff_result);
	    gray_pixel6=gray_pixel6+coeff_result;

	    MulRed7.apply(red_M,red_C7,coeff_result);
	    gray_pixel7=gray_pixel7+coeff_result;
	    MulGreen7.apply(green_M,green_C7,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel7=gray_pixel7+coeff_result;
	    MulBlue7.apply(blue_M,blue_C7,coeff_result);
	    gray_pixel7=gray_pixel7+coeff_result;

	    MulRed8.apply(red_M,red_C8,coeff_result);
	    gray_pixel8=gray_pixel8+coeff_result;
	    MulGreen8.apply(green_M,green_C8,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel8=gray_pixel8+coeff_result;
	    MulBlue8.apply(blue_M,blue_C8,coeff_result);
	    gray_pixel8=gray_pixel8+coeff_result;

	    MulRed9.apply(red_M,red_C9,coeff_result);
	    gray_pixel9=gray_pixel9+coeff_result;
	    MulGreen9.apply(green_M,green_C9,coeff_result);						//using color information to convert to grayscale value for pixel 4
	    gray_pixel9=gray_pixel9+coeff_result;
	    MulBlue9.apply(blue_M,blue_C9,coeff_result);
	    gray_pixel9=gray_pixel9+coeff_result;


	    bit<4> floating=gray_pixel1[3:0];
	    gray_pixel1=gray_pixel1 >> 4;
	    if (floating >= 8) {
		gray_pixel1=gray_pixel1+1;												//If fractional part for the value is above 0.5 (8 in fixed-point notation), ceiling is taken
	    }
	    if (gray_pixel1 > 255) gray_pixel1 = 32w255;
	
	    floating=gray_pixel2[3:0];
	    gray_pixel2=gray_pixel2 >> 4;
	    if (floating >= 8) {
		gray_pixel2=gray_pixel2+1;
	    }
	    if (gray_pixel2 > 255) gray_pixel2 = 32w255;

	    floating=gray_pixel3[3:0];
	    gray_pixel3=gray_pixel3 >> 4;
	    if (floating >= 8) {
		gray_pixel3=gray_pixel3+1;
	    }
	    if (gray_pixel3 > 255) gray_pixel3 = 32w255;

	    floating=gray_pixel4[3:0];
	    gray_pixel4=gray_pixel4 >> 4;
	    if (floating >= 8) {
		gray_pixel4=gray_pixel4+1;
	    }
	    if (gray_pixel4 > 255) gray_pixel4 = 32w255;

	    floating=gray_pixel5[3:0];
	    gray_pixel5=gray_pixel5 >> 4;
	    if (floating >= 8) {
		gray_pixel5=gray_pixel5+1;
	    }
	    if (gray_pixel5 > 255) gray_pixel5 = 32w255;

	    floating=gray_pixel6[3:0];
	    gray_pixel6=gray_pixel6 >> 4;
	    if (floating >= 8) {
		gray_pixel6=gray_pixel6+1;
	    }
	    if (gray_pixel6 > 255) gray_pixel6 = 32w255;

	    floating=gray_pixel7[3:0];
	    gray_pixel7=gray_pixel7 >> 4;
	    if (floating >= 8) {
		gray_pixel7=gray_pixel7+1;
	    }
	    if (gray_pixel7 > 255) gray_pixel7 = 32w255;

	    floating=gray_pixel8[3:0];
	    gray_pixel8=gray_pixel8 >> 4;
	    if (floating >= 8) {
		gray_pixel8=gray_pixel8+1;
	    }
	    if (gray_pixel8 > 255) gray_pixel8 = 32w255;

	    floating=gray_pixel9[3:0];
	    gray_pixel9=gray_pixel9 >> 4;
	    if (floating >= 8) {
		gray_pixel9=gray_pixel9+1;
	    }
	    if (gray_pixel9 > 255) gray_pixel9 = 32w255;

	    if (hdr.udp.srcPort!=10000) {
		    if ( gray_pixel1 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel1 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel1 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel2 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel2 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel2 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel3 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel3 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel3 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel4 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel4 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel4 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel5 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel5 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel5 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel5 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel6 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel6 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel6 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel7 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel7 < 256)  {
			high_gray = high_gray + 1;
		    }
		    if ( gray_pixel8 < 85 ) {
			low_gray = low_gray + 1;
		    }
		   else if ( gray_pixel8 < 170  ) {
			mid_gray = mid_gray + 1;
		    }
		   else if (gray_pixel8 < 256)  {
			high_gray = high_gray + 1;
		    }
		    
		    if ( gray_pixel9 < 85 ) {
			low_gray = low_gray + 1;
	            }
		   else if ( gray_pixel9 < 170  ) {
		   	mid_gray = mid_gray + 1;
	            }
		   else if (gray_pixel9 < 256)  {
		   	high_gray = high_gray + 1;
                    }
	    }
	
	  /*************************************************************************
	  ****************** INTENSITY COMPUTATION  *****************************
	  *************************************************************************/

	    if (min_gray==0) min_gray=9999;
	    if (gray_pixel1 > max_gray) max_gray=gray_pixel1;						//for finding maximum and minimum intensity for contrast calculation
	    if (gray_pixel1 < min_gray && gray_pixel1!=0) min_gray=gray_pixel1;
	    if (gray_pixel2 > max_gray) max_gray=gray_pixel2;						
	    if (gray_pixel2 < min_gray && gray_pixel2!=0) min_gray=gray_pixel2;
	    if (gray_pixel3 > max_gray) max_gray=gray_pixel3;						
	    if (gray_pixel3 < min_gray && gray_pixel3!=0) min_gray=gray_pixel3;
	    if (gray_pixel4 > max_gray) max_gray=gray_pixel4;						
	    if (gray_pixel4 < min_gray && gray_pixel4!=0) min_gray=gray_pixel4;
	    if (gray_pixel5 > max_gray) max_gray=gray_pixel5;						
	    if (gray_pixel5 < min_gray && gray_pixel5!=0) min_gray=gray_pixel5;
	    if (gray_pixel6 > max_gray) max_gray=gray_pixel6;						
	    if (gray_pixel6 < min_gray && gray_pixel6!=0) min_gray=gray_pixel6;
	    if (gray_pixel7 > max_gray) max_gray=gray_pixel7;						
	    if (gray_pixel7 < min_gray && gray_pixel7!=0) min_gray=gray_pixel7;
	    if (gray_pixel8 > max_gray) max_gray=gray_pixel8;						
	    if (gray_pixel8 < min_gray && gray_pixel8!=0) min_gray=gray_pixel8;
	    if (gray_pixel9 > max_gray) max_gray=gray_pixel9;						
	    if (gray_pixel9< min_gray && gray_pixel9!=0) min_gray=gray_pixel9;

	   intensity_count=intensity_count+gray_pixel1;
	   intensity_count=intensity_count+gray_pixel2;
	   intensity_count=intensity_count+gray_pixel3;
	   intensity_count=intensity_count+gray_pixel4;
	   intensity_count=intensity_count+gray_pixel5;
	   intensity_count=intensity_count+gray_pixel6;
	   intensity_count=intensity_count+gray_pixel7;
	   intensity_count=intensity_count+gray_pixel8;
	   intensity_count=intensity_count+gray_pixel9;

	  /*************************************************************************
	  ************************* LAPLACIAN FILTER  *****************************
   	  *************************************************************************/

	    laplace=8*(int<32>)gray_pixel5-(int<32>)gray_pixel1-(int<32>)gray_pixel2-(int<32>)gray_pixel3-(int<32>)gray_pixel4-(int<32>)gray_pixel6-(int<32>)gray_pixel7-(int<32>)gray_pixel8-(int<32>)gray_pixel9;
	    if (prev_laplace!=0) {
		if (laplace*prev_laplace < 0) {
			edge_count=edge_count+1;    
		}
            }
	    if (laplace != 0) {
		prev_laplace=laplace;
	    }


	    if (hdr.udp.srcPort==10000)  {

		/*************************************************************************
		***********************FEATURE CALCULATION  ***************************
		*************************************************************************/
		bit<32> total_pixel=packetno*9;
		total_pixel=total_pixel << 4;
		bit<32> divresult=32w0;

		//Low Intensity Ratio
		low_gray=low_gray << 4;
		DivLowIntensity.apply(low_gray,total_pixel,divresult);
		low_gray=divresult;

		//Mid Intensity Ratio
		mid_gray=mid_gray << 4;
		DivMidIntensity.apply(mid_gray,total_pixel,divresult);
		mid_gray=divresult;

		//High Intensity Ratio
		high_gray=high_gray << 4;
		DivHighIntensity.apply(high_gray,total_pixel,divresult);
		high_gray=divresult;		
		
		//Contrast
		bit<32> contrast_num=max_gray-min_gray;
		contrast_num=contrast_num <<4;
		bit<32> contrast_den=max_gray+min_gray;
		contrast_den=contrast_den <<4;
		DivContrast.apply(contrast_num,contrast_den,contrast);

		//Brightness
		intensity_count=intensity_count << 4;
		DivBrightness.apply(intensity_count,total_pixel,brightness);
	
		feature1=count;
		feature2=low_gray;
		feature3=mid_gray;
		feature4=high_gray;
		feature5=edge_count;
		feature6=brightness;
		feature7=contrast;

		/*************************************************************************
		********************** IMAGE CLASSIFICATION  ***************************
		*************************************************************************/
		decision_table.apply();
		hdr.counts.class_decision=final_class;
		hdr.counts.sequence=packetno;

		low_gray=0;
		mid_gray=0;
		high_gray=0;
		count=0;
		min_gray=0;
		max_gray=0;
	    }


	    //write the counter value to register
	    count_reg.write(0,count);
	    count_intensity.write(0,intensity_count);
	    count_edge.write(0,edge_count);
	    laplace_prev.write(0,prev_laplace);
	    gray_reg.write(0,low_gray);
	    gray_reg.write(1,mid_gray);
	    gray_reg.write(2,high_gray);
	    gray_maxmin.write(0,min_gray);
	    gray_maxmin.write(1,max_gray);
	

	    forwarding.apply();
	    
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        //packet.emit(hdr.tcp);
	packet.emit(hdr.udp);
	//packet.emit(hdr.colors);
	packet.emit(hdr.counts);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
