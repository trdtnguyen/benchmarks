#!/bin/bash

### goto user homedir and remove previous file
rm -f '$2'
title1='buffer pool: 256M'
title2='buffer pool: 1024M'
gnuplot << EOP

### set data source file
datafile = '$1'

### set graph type and size
set terminal jpeg size 640,480

### set titles
set grid x y
set xlabel "Time (sec)"
set ylabel "Transactions"

### set output filename
set output '$2'

### build graph
# plot datafile with lines
plot datafile u 1:2 title '${title1}' with lines, \
datafile u 3:4 title '${title2}' with lines;

EOP
