#!/bin/bash

for f in *.png;
do
convert "$f" -resize 20% "${f%.*}".png
done
