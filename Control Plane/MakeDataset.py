#!/usr/bin/env python3

import argparse
import sys
import numpy as np
import random
import glob
import math
import statistics

from PIL import Image
from fxpmath import Fxp



images = []
names = []
pixels = []
file=open("dataset.txt","a")

for f in glob.iglob("MNIST27/*"):
    image=Image.open(f)
    iname=f.replace(".jpg","")
    iname=iname.replace("MNIST27/","")
    label=''.join([i for i in iname if not i.isdigit()])
    names.append(label)
    images.append(image)
    w,h=image.size
    pixels.append(w*h)

print(pixels)
value=statistics.median(pixels)
print(value)
dimension=int(math.sqrt(value))
dimension=int(dimension/3)*3
print(dimension)
    
n=0
for image in images:
    image=image.resize((dimension,dimension))
    rgb_image=image.convert("RGB")
    gray_image=image.convert("L")
    w,h=rgb_image.size
    colors=set()
    total_colors=0
    low_gray=0
    mid_gray=0
    high_gray=0
    contrast=0
    max_gray=0
    min_gray=9999
    intensity=0
    edge_count=0

    for j in range(h):
        for i in range(w):
            pixel=rgb_image.getpixel((i,j))
            gray_pixel=gray_image.getpixel((i,j))
            intensity=intensity+gray_pixel
            if gray_pixel < 85:
                low_gray=low_gray+1
            elif gray_pixel < 170:
                mid_gray=mid_gray+1
            else:
                high_gray=high_gray+1

            if gray_pixel > max_gray:
                max_gray=gray_pixel
            if gray_pixel < min_gray:
                min_gray=gray_pixel

            if pixel in colors:
                continue
            else:
                total_colors=total_colors+1
                colors.add(pixel)

    contrast=(max_gray-min_gray)/(max_gray+min_gray)
    brightness=intensity/(h*w)    
    contrastfxp=Fxp(contrast, signed=False, n_word=32, n_frac=4)
    brightnessfxp=Fxp(brightness, signed=False, n_word=32, n_frac=4)
    prev_laplace=0
    for column in range(0,h,3):
        for row in range(0,w,3):
            gray_pixel1=gray_image.getpixel((row,column))
            gray_pixel2=gray_image.getpixel((row,column+1))
            gray_pixel3=gray_image.getpixel((row,column+2))


            gray_pixel4=gray_image.getpixel((row+1,column))
            gray_pixel5=gray_image.getpixel((row+1,column+1))
            gray_pixel6=gray_image.getpixel((row+1,column+2))


            gray_pixel7=gray_image.getpixel((row+2,column))
            gray_pixel8=gray_image.getpixel((row+2,column+1))
            gray_pixel9=gray_image.getpixel((row+2,column+2))

            
            laplace=-1*(gray_pixel1+gray_pixel2+gray_pixel3+gray_pixel4+gray_pixel6+gray_pixel7+gray_pixel8+gray_pixel9)+8*gray_pixel5
            if (prev_laplace!=0):
                if (laplace*prev_laplace<0):
                    edge_count=edge_count+1
            if (laplace!=0):            
                prev_laplace=laplace
    
    file.write(str(total_colors)+",")
    file.write(str(low_gray)+",")
    file.write(str(mid_gray)+",")
    file.write(str(high_gray)+",")
    file.write(str(edge_count)+",")
    file.write(str(brightnessfxp.val)+",")
    file.write(str(contrastfxp.val)+","+str(names[n])+"\n")
    n=n+1
    image.close()

file.close()       


