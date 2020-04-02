#!/bin/sh

qbatch -b slurm -w 00:40:00 qbatch__dtseries_to_gradients.txt -c 8 -j 4 