#!/usr/bin/pyhton
import sys
import numpy as np

file = sys.argv[1]

file1 = open(file, 'r') 
Lines = file1.readlines()
i=0
mb=[]
latency=[]
for line in Lines:
	i = i + 1
	z = line.strip().split(" ")
	try:
		mb.append(float(z[1]))
	except:
		pass
#	latency.append(float(z[1]))

print('{} {} {}'.format(file.split('/')[-1].split('_')[-1], np.mean(mb), np.std(mb)))
